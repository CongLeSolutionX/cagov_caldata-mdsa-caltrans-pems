{{ config(
    materialized="incremental",
    cluster_by="sample_date",
    unique_key=["id","sample_timestamp","sample_date"],
    snowflake_warehouse = get_snowflake_refresh_warehouse(small="XS", big="XL")
) }}
select
    split_part(split_part(filename, '/', 4), '=D', 2)::int as district,
    vds_id::varchar as id,
    sample_date,
    sample_time as sample_timestamp,
    volume_1,
    volume_2,
    volume_3,
    volume_4,
    volume_5,
    volume_6,
    volume_7,
    volume_8,
    volume_9,
    volume_10,
    volume_11,
    volume_12,
    volume_13,
    volume_14,
    occupancy_1,
    occupancy_2,
    occupancy_3,
    occupancy_4,
    occupancy_5,
    occupancy_6,
    occupancy_7,
    occupancy_8,
    occupancy_9,
    occupancy_10,
    occupancy_11,
    occupancy_12,
    occupancy_13,
    occupancy_14,
    speed_1,
    speed_2,
    speed_3,
    speed_4,
    speed_5,
    speed_6,
    speed_7,
    speed_8,
    speed_9,
    speed_10,
    speed_11,
    speed_12,
    speed_13,
    speed_14
from {{ source('db96', 'vds30sec') }}
where true and {{ make_model_incremental('sample_date') }}
qualify row_number() over (partition by vds_id, sample_date, sample_time order by vds_id) = 1
