{{ config(
    materialized="incremental",
    unique_key=['sample_date'],
    snowflake_warehouse=get_snowflake_refresh_warehouse(big="XL")
) }}

-- read observed and imputed five minutes data
with obs_imputed_five_minutes_agg as (
    select *
    from {{ ref('int_imputation__detector_imputed_agg_five_minutes') }}
    where station_type in ('HV', 'ML') and {{ make_model_incremental('sample_date') }}
),

imputation_status_count as (
    select
        sample_date,
        count(*) as sample_ct,
        count_if(occupancy_imputation_method = 'local') as occ_local_imputation_sample,
        count_if(occupancy_imputation_method = 'regional') as occ_regional_imputation_sample,
        count_if(occupancy_imputation_method = 'global') as occ_global_imputation_sample,
        count_if(occupancy_imputation_method = 'local_avg') as occ_local_avg_imputation_sample,
        count_if(occupancy_imputation_method = 'regional_avg') as occ_regional_avg_imputation_sample,
        count_if(occupancy_imputation_method = 'observed') as occ_observed_sample,
        count_if(occupancy_imputation_method is NULL) as occ_unobserved_unimputed,
        count_if(volume_imputation_method = 'local') as vol_local_imputation_sample,
        count_if(volume_imputation_method = 'regional') as vol_regional_imputation_sample,
        count_if(volume_imputation_method = 'global') as vol_global_imputation_sample,
        count_if(volume_imputation_method = 'local_avg') as vol_local_avg_imputation_sample,
        count_if(volume_imputation_method = 'regional_avg') as vol_regional_avg_imputation_sample,
        count_if(volume_imputation_method = 'observed') as vol_observed_sample,
        count_if(volume_imputation_method is NULL) as vol_unobserved_unimputed,
        count_if(speed_imputation_method = 'local') as speed_local_imputation_sample,
        count_if(speed_imputation_method = 'regional') as speed_regional_imputation_sample,
        count_if(speed_imputation_method = 'global') as speed_global_imputation_sample,
        count_if(speed_imputation_method = 'local_avg') as speed_local_avg_imputation_sample,
        count_if(speed_imputation_method = 'regional_avg') as speed_regional_avg_imputation_sample,
        count_if(speed_imputation_method = 'observed') as speed_observed_sample,
        count_if(speed_imputation_method is NULL) as speed_unobserved_unimputed,
        count_if(occupancy_imputation_method != 'observed' and occupancy_imputation_method is not NULL)
            as occ_imputed_sample,
        count_if(volume_imputation_method != 'observed' and volume_imputation_method is not NULL) as vol_imputed_sample,
        count_if(speed_imputation_method != 'observed' and speed_imputation_method is not NULL) as speed_imputed_sample
    from obs_imputed_five_minutes_agg
    group by sample_date
),


sample_count as (
    select
        *,
        case
            when
                coalesce(occ_unobserved_unimputed, 0)
                + coalesce(occ_imputed_sample, 0)
                + coalesce(occ_observed_sample, 0)
                = sample_ct
                then 'pass'
            else 'fail'
        end as occ_imputation_check,

        case
            when
                coalesce(vol_unobserved_unimputed, 0)
                + coalesce(vol_imputed_sample, 0)
                + coalesce(vol_observed_sample, 0)
                = sample_ct
                then 'pass'
            else 'fail'
        end as vol_imputation_check,

        case
            when
                coalesce(speed_unobserved_unimputed, 0)
                + coalesce(speed_imputed_sample, 0)
                + coalesce(speed_observed_sample, 0)
                = sample_ct
                then 'pass'
            else 'fail'
        end as speed_imputation_check,

        case
            when occ_observed_sample = sample_ct then 'observed'
            else 'observed_imputed'
        end as occ_observed,

        case
            when vol_observed_sample = sample_ct then 'observed'
            else 'observed_imputed'
        end as vol_observed,

        case
            when speed_observed_sample = sample_ct then 'observed'
            else 'observed_imputed'
        end as speed_observed

    from imputation_status_count
)

select *
from sample_count
