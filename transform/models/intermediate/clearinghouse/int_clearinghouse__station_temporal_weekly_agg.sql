{{ config(materialized='table') }}

-- read the volume, occupancy and speed daily level data
with station_daily_data as (
    select
        *,
        -- Extracting the week and year
        year(sample_date) as sample_year,
        weekofyear(sample_date) as sample_week,

        date_trunc('week', sample_date) as sample_week_start_date,
        -- Extracting the week
        dateadd(day, 6, date_trunc('week', sample_date)) as sample_week_end_date
    from {{ ref('int_clearinghouse__station_temporal_daily_agg') }}
    -- we do not want to calculate incomplete week aggregation
    where date_trunc(week, sample_date) != date_trunc(week, current_date)
),

-- now aggregate daily volume, occupancy and speed to weekly
weekly_station_level_spatial_temporal_metrics as (
    select
        id,
        sample_year,
        sample_week,
        sample_week_start_date,
        sample_week_end_date,
        city,
        county,
        district,
        type,
        sum(volume_sum) as volume_sum,
        avg(occupancy_avg) as occupancy_avg,
        sum(daily_vmt) as weekly_vmt,
        sum(daily_vht) as weekly_vht,
        weekly_vmt / nullifzero(weekly_vht) as weekly_q_value,
        -- travel time
        60 / nullifzero(weekly_q_value) as weekly_tti,
        {% for value in var("V_t") %}
            sum(delay_{{ value }}_mph)
                as delay_{{ value }}_mph
            {% if not loop.last %}
                ,
            {% endif %}

        {% endfor %},
        {% for value in var("V_t") %}
            sum(lost_productivity_{{ value }}_mph)
                as lost_productivity_{{ value }}_mph
            {% if not loop.last %}
                ,
            {% endif %}

        {% endfor %}
    from station_daily_data
    group by id, sample_year, sample_week, sample_week_start_date, sample_week_end_date, city, county, district, type
)

select * from weekly_station_level_spatial_temporal_metrics
