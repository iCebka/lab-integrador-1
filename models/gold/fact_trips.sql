select

    -- Primary key
    trip_key,

    -- Dimension foreign keys
    vendor_id as vendor_key,
    payment_type as payment_key,
    ratecode_id as rate_code_key,

    pickup_location_id as pickup_location_key,
    dropoff_location_id as dropoff_location_key,

    to_number(
        to_char(pickup_datetime::date, 'YYYYMMDD')
    ) as pickup_date_key,

    to_number(
        to_char(dropoff_datetime::date, 'YYYYMMDD')
    ) as dropoff_date_key,

    -- Trip attributes
    pickup_datetime,
    dropoff_datetime,
    store_and_fwd_flag,

    -- Measures
    passenger_count,
    trip_distance,
    trip_duration_seconds,

    fare_amount,
    extra,
    mta_tax,
    tip_amount,
    tolls_amount,
    improvement_surcharge,
    congestion_surcharge,
    airport_fee,
    cbd_congestion_fee,
    total_amount,

    -- Lineage
    source_period

from {{ ref('slv_yellow_taxi_trips') }}