with trips as (

    select *
    from {{ ref('slv_yellow_taxi_trips') }}
    where is_valid_for_analysis

)

select
    md5(
        source_file || '|' || source_row_number
    ) as trip_key,

    -- Foreign keys
    vendor_id as vendor_key,
    payment_type as payment_key,
    coalesce(ratecode_id, -1) as rate_code_key,

    pickup_location_id as pickup_zone_key,
    dropoff_location_id as dropoff_zone_key,

    to_number(
        to_char(pickup_datetime::date, 'YYYYMMDD')
    ) as pickup_date_key,

    to_number(
        to_char(dropoff_datetime::date, 'YYYYMMDD')
    ) as dropoff_date_key,

    -- Degenerate/detail attributes
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

    -- Useful analytical quality attributes
    has_zero_duration,
    has_negative_fare,
    has_negative_total,

    -- Lineage
    source_file,
    source_row_number,
    source_period,
    loaded_at

from trips