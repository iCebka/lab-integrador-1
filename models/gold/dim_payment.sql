select distinct
    payment_type as payment_key,
    payment_type
from {{ ref('slv_yellow_taxi_trips') }}