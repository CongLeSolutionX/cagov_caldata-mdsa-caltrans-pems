/*{{ config(
    materialized="incremental",
    cluster_by=["sample_date"],
    unique_key=["ID", "SAMPLE_TIMESTAMP"],
    snowflake_warehouse=get_snowflake_refresh_warehouse()
) }}
*/
with station_raw as (
    select
        *,
        /* Create a timestamp truncated down to the nearest five
         minute bucket. This will be the the timestamp on which
         we aggregate. If a 30-second interval straddles two different
         buckets, it will be assigned to the one latter one due to
         the floor() call.
        */
        dateadd(
            'minute',
            floor(minute(sample_timestamp) / 5) * 5,
            trunc(sample_timestamp, 'hour')
        ) as sample_timestamp_trunc
    from {{ ref('stg_clearinghouse__station_raw') }}
    where sample_date >= dateadd(year, -1, current_date())
/*    {% if is_incremental() %}
        -- Look back two days to account for any late-arriving data
        where sample_date > (
            select dateadd(day, -2, max(sample_date)) from {{ this }}
        )
    {% endif %}
*/
),

aggregated as (
    select
        id,
        sample_date,
        sample_timestamp_trunc as sample_timestamp,
        -- Sum of all the flow values
        sum(flow_1) as flow_1,
        sum(flow_2) as flow_2,
        sum(flow_3) as flow_3,
        sum(flow_4) as flow_4,
        sum(flow_5) as flow_5,
        sum(flow_6) as flow_6,
        sum(flow_7) as flow_7,
        sum(flow_8) as flow_8,
        -- Average of all the occupancy values
        avg(occupancy_1) as occupancy_1,
        avg(occupancy_2) as occupancy_2,
        avg(occupancy_3) as occupancy_3,
        avg(occupancy_4) as occupancy_4,
        avg(occupancy_5) as occupancy_5,
        avg(occupancy_6) as occupancy_6,
        avg(occupancy_7) as occupancy_7,
        avg(occupancy_8) as occupancy_8
    from station_raw
    group by id, sample_date, sample_timestamp_trunc
),

aggregated_speed as (
    select
        *,
        --For speed I used the following formula to get speed: 
        --SPEED = SUM(FLOW)/AVG(OCCUPANCY)/600 which resulted in 
        --values from 0 to 5
        --On 3/22/24 I updated the formula to use a vehicle effective length
        --of 22 feet (16 ft vehicle + 6 ft detector zone) feet and using 
        --a conversion to get miles per hour (5280 ft / mile and 12
        --5-minute intervals in an hour).
        case
            when flow_1 = 0 or occupancy_1 = 0 then 0
            when flow_1 is null or occupancy_1 is null then null
            --else (flow_1 * 22) / occupancy_1 / 5280 * 12
            else (flow_1) / occupancy_1 / 600
        end as speed_1,
        case
            when flow_2 = 0 or occupancy_2 = 0 then 0
            when flow_2 is null or occupancy_2 is null then null
            else (flow_2 * 22) / occupancy_2 / 5280 * 12
        end as speed_2,
        case
            when flow_3 = 0 or occupancy_3 = 0 then 0
            when flow_3 is null or occupancy_3 is null then null
            else (flow_3 * 22) / occupancy_3 / 5280 * 12
        end as speed_3,
        case
            when flow_4 = 0 or occupancy_4 = 0 then 0
            when flow_4 is null or occupancy_4 is null then null
            else (flow_4 * 22) / occupancy_4 / 5280 * 12
        end as speed_4,
        case
            when flow_5 = 0 or occupancy_5 = 0 then 0
            when flow_5 is null or occupancy_5 is null then null
            else (flow_5 * 22) / occupancy_5 / 5280 * 12
        end as speed_5,
        case
            when flow_6 = 0 or occupancy_6 = 0 then 0
            when flow_6 is null or occupancy_6 is null then null
            else (flow_6 * 22) / occupancy_6 / 5280 * 12
        end as speed_6,
        case
            when flow_7 = 0 or occupancy_7 = 0 then 0
            when flow_7 is null or occupancy_7 is null then null
            else (flow_7 * 22) / occupancy_7 / 5280 * 12
        end as speed_7,
        case
            when flow_8 = 0 or occupancy_8 = 0 then 0
            when flow_8 is null or occupancy_8 is null then null
            else (flow_8 * 22) / occupancy_8 / 5280 * 12
        end as speed_8

    from aggregated
--    group by id, sample_date, sample_timestamp 
)

select * from aggregated_speed
--group by id, sample_date, sample_timestamp
