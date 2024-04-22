{{ config(
    materialized="incremental",
    cluster_by=["sample_date"],
    unique_key=["id", "lane", "sample_timestamp"],
    snowflake_warehouse = get_snowflake_refresh_warehouse(small="XL")
) }}

with
samples_per_station as (
    select * from {{ ref ('int_pems__diagnostic_samples_per_station') }}
    {% if is_incremental() %}
        -- Look back to account for any late-arriving data
        where
            sample_date > (
                select
                    dateadd(
                        day,
                        {{ var("incremental_model_look_back") }},
                        max(sample_date)
                    )
                from {{ this }}
            )
            {% if target.name != 'prd' %}
                and sample_date >= (
                    dateadd(
                        day,
                        {{ var("dev_model_look_back") }},
                        current_date()
                    )
                )
            {% endif %}
    {% elif target.name != 'prd' %}
        where sample_date >= dateadd(day, {{ var("dev_model_look_back") }}, current_date())
    {% endif %}
),

district_feed_check as (
    select
        samples_per_station.district,
        case
            when (count_if(samples_per_station.sample_ct > 0)) > 0 then 'Yes'
            else 'No'
        end as district_feed_working
    from samples_per_station
    inner join {{ ref('districts') }} as d
        on d.district_id = samples_per_station.district
    group by samples_per_station.district
),

detector_status as (
    select
        set_assgnmt.active_date,
        set_assgnmt.station_id,
        set_assgnmt.district,
        set_assgnmt.type,
        sps.* exclude (district, station_id),
        dfc.district_feed_working,
        case
            when dfc.district_feed_working = 'No' then 'District Feed Down'
            when sps.sample_ct = 0 or sps.sample_ct is null
                then 'Down/No Data'
            /* # of samples < 60% of the max collected during the test period
            max value: 2 samples per min * 60 mins/hr * 17 hrs in a day == 1224
            btwn 1 and 1224 is too few samples */
            when sps.sample_ct between 1 and (0.6 * ({{ var("detector_status_max_sample_value") }}))
                then 'Insufficient Data'
            when
                set_assgnmt.station_diagnostic_method_id = 'ramp'
                and sps.zero_vol_ct / ({{ var("detector_status_max_sample_value") }})
                > (set_assgnmt.zero_flow_percent / 100)
                then 'Card Off'
            when
                set_assgnmt.station_diagnostic_method_id = 'mainline'
                and sps.zero_occ_ct / ({{ var("detector_status_max_sample_value") }})
                > (set_assgnmt.zero_occupancy_percent / 100)
                then 'Card Off'
            when
                set_assgnmt.station_diagnostic_method_id = 'ramp'
                and sps.high_volume_ct / ({{ var("detector_status_max_sample_value") }})
                > (set_assgnmt.high_flow_percent / 100)
                then 'High Val'
            when
                set_assgnmt.station_diagnostic_method_id = 'mainline'
                and sps.high_occupancy_ct / ({{ var("detector_status_max_sample_value") }})
                > (set_assgnmt.high_occupancy_percent / 100)
                then 'High Val'
            when
                set_assgnmt.station_diagnostic_method_id = 'mainline'
                and sps.zero_vol_pos_occ_ct / ({{ var("detector_status_max_sample_value") }})
                > (set_assgnmt.flow_occupancy_percent / 100)
                then 'Intermittent'
            when
                set_assgnmt.station_diagnostic_method_id = 'mainline'
                and sps.zero_occ_pos_vol_ct / ({{ var("detector_status_max_sample_value") }})
                > (set_assgnmt.occupancy_flow_percent / 100)
                then 'Intermittent'
            --constant occupancy case needed
            --Feed unstable case needed
            else 'Good'
        end as status
    from {{ ref('int_pems__det_diag_set_assignment') }} as set_assgnmt
    left join samples_per_station as sps
        on
            set_assgnmt.station_id = sps.station_id
            and set_assgnmt.active_date = sps.sample_date
    inner join district_feed_check as dfc
        on set_assgnmt.district = dfc.district
)

select * from detector_status
