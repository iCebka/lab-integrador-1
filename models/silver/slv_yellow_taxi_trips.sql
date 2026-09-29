with bronze as (

    select *
    from {{ ref('brz_yellow_taxi_trips') }}

),

deduplicated as (

    select *
    from bronze

    qualify row_number() over (
        partition by hash(raw_record)
        order by source_file, source_row_number
    ) = 1

),

typed as (

    select
        raw_record:"VendorID"::integer as vendor_id,

        to_timestamp_ntz(
            raw_record:"tpep_pickup_datetime"::number,
            6
        ) as pickup_datetime,

        to_timestamp_ntz(
            raw_record:"tpep_dropoff_datetime"::number,
            6
        ) as dropoff_datetime,

        raw_record:"passenger_count"::integer
            as passenger_count,

        raw_record:"trip_distance"::float
            as trip_distance,

        raw_record:"RatecodeID"::integer
            as ratecode_id,

        upper(trim(
            raw_record:"store_and_fwd_flag"::varchar
        )) as store_and_fwd_flag,

        raw_record:"PULocationID"::integer
            as pickup_location_id,

        raw_record:"DOLocationID"::integer
            as dropoff_location_id,

        raw_record:"payment_type"::integer
            as payment_type,

        raw_record:"fare_amount"::number(18, 2)
            as fare_amount,

        raw_record:"extra"::number(18, 2)
            as extra,

        raw_record:"mta_tax"::number(18, 2)
            as mta_tax,

        raw_record:"tip_amount"::number(18, 2)
            as tip_amount,

        raw_record:"tolls_amount"::number(18, 2)
            as tolls_amount,

        raw_record:"improvement_surcharge"::number(18, 2)
            as improvement_surcharge,

        raw_record:"total_amount"::number(18, 2)
            as total_amount,

        raw_record:"congestion_surcharge"::number(18, 2)
            as congestion_surcharge,

        raw_record:"Airport_fee"::number(18, 2)
            as airport_fee,

        raw_record:"cbd_congestion_fee"::number(18, 2)
            as cbd_congestion_fee,

        source_file,
        source_row_number,
        source_period,
        loaded_at

    from deduplicated

),

validated as (

    select
        md5(
            source_file || '|' || source_row_number
        ) as trip_key,

        *,

        datediff(
            second,
            pickup_datetime,
            dropoff_datetime
        ) as trip_duration_seconds

    from typed

)

select *
from validated

where
    vendor_id is not null

    and pickup_datetime is not null
    and dropoff_datetime is not null

    and passenger_count is not null
    and trip_distance is not null
    and ratecode_id is not null
    and store_and_fwd_flag is not null

    and pickup_location_id is not null
    and dropoff_location_id is not null
    and payment_type is not null

    and fare_amount is not null
    and extra is not null
    and mta_tax is not null
    and tip_amount is not null
    and tolls_amount is not null
    and improvement_surcharge is not null
    and total_amount is not null
    and congestion_surcharge is not null
    and airport_fee is not null
    and cbd_congestion_fee is not null

    and store_and_fwd_flag in ('Y', 'N')

    and dropoff_datetime > pickup_datetime

    and to_char(pickup_datetime, 'YYYY-MM') = source_period

    and trip_distance between 0 and 1000

    and passenger_count between 0 and 20

    and pickup_location_id > 0
    and dropoff_location_id > 0

    and fare_amount >= 0
    and total_amount >= 0