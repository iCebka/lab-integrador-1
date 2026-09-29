select distinct
    ratecode_id as rate_code_key,
    ratecode_id
from {{ ref('slv_yellow_taxi_trips') }}