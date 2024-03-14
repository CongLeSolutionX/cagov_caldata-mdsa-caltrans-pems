/*
This SQL file assigns which sets of calculations will be used for
a station based on information in from the station metadata
The DET_DIAG_SET_ID varialbe assigns 1 of 5 values for detector
diagnostic evaluations. The DET_DIAG_METHOD_ID variable assigns
1 of 2 values for detector diagnostic evaluations.
*/
select
    meta_date,
    id as station_id,
    district,
    type,
    case
        /*when LIKE(UPPER(THRESHOLD_SET), "LOW%") then "Low_Volume"
        This value is currently in district config file but not in
        our current metadata files
        when LIKE(UPPER(THRESHOLD_SET), "RURAL%") then "Rural"
        We need the definition of when a station is considered
        Rural from Iteris
        */
        when district = 11 then 'Urban_D11'
        when district = 6 then 'D6_Ramps'
        else 'Urban'
    end as det_diag_set_id,
    case
        when type = 'OR' then 'ramp'
        else 'mainline'
    end as det_diag_method_id

from {{ ref('int_vds__most_recent_station_meta') }}
