/* Per the PEMS Performance Measrues documentation (https://pems.dot.ca.gov/?dnode=Help&content=help_calc#perf)
Delay can never be negative. Instead of coercing Delay to be positive or only selecting instances where Delay
is positive we have written a test to cacth these instances. */
select
    delay_35_mph,
    delay_40_mph,
    delay_45_mph,
    delay_50_mph,
    delay_55_mph,
    delay_60_mph

from {{ ref('int_performance__five_min_perform_metrics' ) }}
where
    delay_35_mph < 0
    or delay_40_mph < 0
    or delay_45_mph < 0
    or delay_50_mph < 0
    or delay_55_mph < 0
    or delay_60_mph < 0
