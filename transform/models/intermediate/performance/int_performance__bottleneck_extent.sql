{{ config(
    materialized="incremental",
    cluster_by=["sample_date"],
    unique_key=["station_id", "sample_date", "sample_timestamp"],
    snowflake_warehouse = get_snowflake_refresh_warehouse(small="XS")
) }}

with

bottleneck_duration as (
    select * from {{ ref ("int_performance__bottleneck_duration") }}
    where {{ make_model_incremental('sample_date') }}
),

extent_cte as (
    select
        station_id,
        sample_date,
        sample_timestamp,
        is_bottleneck,
        case
            when is_bottleneck = true
                then sum(length) over (partition by sample_timestamp, station_id)
        end as extent
    from bottleneck_duration
)

select * from extent_cte
