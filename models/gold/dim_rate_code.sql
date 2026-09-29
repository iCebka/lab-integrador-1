select distinct
    ratecode_id as rate_code_key,
    ratecode_id,
    true as is_reported
from {{ ref('slv_yellow_taxi_trips') }}
where ratecode_id is not null

union all

select
    -1 as rate_code_key,
    null as ratecode_id,
    false as is_reported