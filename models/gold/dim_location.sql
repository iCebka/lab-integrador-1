with locations as (

    select
        pickup_location_id as location_id
    from {{ ref('slv_yellow_taxi_trips') }}

    union

    select
        dropoff_location_id as location_id
    from {{ ref('slv_yellow_taxi_trips') }}

)

select
    location_id as location_key,
    location_id
from locations