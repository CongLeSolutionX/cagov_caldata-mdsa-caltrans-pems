{{ config(materialized='table') }}

-- read the volume, occupancy and speed daily level data
with station_monthly_data as (
    select *
    from {{ ref('int_performance__station_metrics_agg_monthly') }}
),

unpivot_combined as (
    select
        district,
        sample_month,
        target_speed,
        sum(coalesce(delay, 0)) as delay,
        sum(coalesce(lost_productivity, 0)) as lost_productivity
    from (
        {% for value in var("V_t") %}
            select
                district,
                sample_month,
                '{{ value }}' as target_speed,
                nullif(delay_{{ value }}_mph, 0) as delay,
                nullif(lost_productivity_{{ value }}_mph, 0) as lost_productivity
            from
                station_monthly_data
            {% if not loop.last %} union all {% endif %}
        {% endfor %}
    ) as combined_metrics
    group by
        district, sample_month, target_speed
)

select * from unpivot_combined
