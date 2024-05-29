{{ config(materialized='table') }}

-- read the volume, occupancy and speed daily level data
with station_daily_data as (
    select
        id,
        lane,
        city,
        county,
        district,
        type,
        volume_sum,
        occupancy_avg,
        daily_speed,
        daily_vmt,
        daily_vht,
        delay_35_mph,
        delay_40_mph,
        delay_45_mph,
        delay_50_mph,
        delay_55_mph,
        delay_60_mph,
        lost_productivity_35_mph,
        lost_productivity_40_mph,
        lost_productivity_45_mph,
        lost_productivity_50_mph,
        lost_productivity_55_mph,
        lost_productivity_60_mph,
        concat(extract(year from sample_date), '-', lpad(cast(extract(month from sample_date) as string), 2, '0')) as sample_year_month
    from {{ ref('int_clearinghouse__temporal_daily_agg') }}
),

-- now aggregate daily volume, occupancy and speed to weekly
monthly_spatial_temporal_metrics as (
    select
        id,
        lane,
        city,
        county,
        district,
        type,
        sum(volume_sum) as volume_sum,
        avg(occupancy_avg) as occupancy_avg,
        sum(daily_vmt) as monthly_vmt,
        sum(daily_vht) as monthly_vht,
        monthly_vmt / nullifzero(monthly_vht) as monthly_q_value,
        -- travel time
        60 / nullifzero(monthly_q_value) as monthly_tti,
        sum(delay_35_mph) as delay_35_mph,
        sum(delay_40_mph) as delay_40_mph,
        sum(delay_45_mph) as delay_45_mph,
        sum(delay_50_mph) as delay_50_mph,
        sum(delay_55_mph) as delay_55_mph,
        sum(delay_60_mph) as delay_60_mph,
        sum(lost_productivity_35_mph) as lost_productivity_35_mph,
        sum(lost_productivity_40_mph) as lost_productivity_40_mph,
        sum(lost_productivity_45_mph) as lost_productivity_45_mph,
        sum(lost_productivity_50_mph) as lost_productivity_50_mph,
        sum(lost_productivity_55_mph) as lost_productivity_55_mph,
        sum(lost_productivity_60_mph) as lost_productivity_60_mph
    from station_daily_data
    group by id, sample_year_month, lane, city, county, district, type
)

select * from monthly_spatial_temporal_metrics
