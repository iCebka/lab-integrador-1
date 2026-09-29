with zones as (

    select pickup_location_id as zone_key
    from {{ ref('slv_yellow_taxi_trips') }}

    union

    select dropoff_location_id as zone_key
    from {{ ref('slv_yellow_taxi_trips') }}

)

select
    zone_key,
    zone_key as location_id
from zones
where zone_key is not null