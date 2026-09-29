select distinct
    vendor_id as vendor_key,
    vendor_id
from {{ ref('slv_yellow_taxi_trips') }}
where vendor_id is not null