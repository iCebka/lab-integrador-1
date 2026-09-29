with bronze as (

    select *
    from {{ ref('brz_yellow_taxi_trips') }}

),

deduplicated as (

    select *
    from bronze

    qualify row_number() over (
        partition by hash(raw_record)
        order by loaded_at, source_file, source_row_number
    ) = 1

),

typed as (

    select
        raw_record:"VendorID"::integer
            as vendor_id,

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

        raw_record:"store_and_fwd_flag"::varchar
            as store_and_fwd_flag,

        raw_record:"PULocationID"::integer
            as pickup_location_id,

        raw_record:"DOLocationID"::integer
            as dropoff_location_id,

        raw_record:"payment_type"::integer
            as payment_type,

        raw_record:"fare_amount"::float
            as fare_amount,

        raw_record:"extra"::float
            as extra,

        raw_record:"mta_tax"::float
            as mta_tax,

        raw_record:"tip_amount"::float
            as tip_amount,

        raw_record:"tolls_amount"::float
            as tolls_amount,

        raw_record:"improvement_surcharge"::float
            as improvement_surcharge,

        raw_record:"total_amount"::float
            as total_amount,

        raw_record:"congestion_surcharge"::float
            as congestion_surcharge,

        raw_record:"Airport_fee"::float
            as airport_fee,

        raw_record:"cbd_congestion_fee"::float
            as cbd_congestion_fee,

        source_file,
        source_row_number,
        source_period,
        loaded_at

    from deduplicated

),

quality as (

    select
        *,

        case
            when dropoff_datetime > pickup_datetime
            then datediff(
                second,
                pickup_datetime,
                dropoff_datetime
            )
        end as trip_duration_seconds,

        dropoff_datetime < pickup_datetime
            as has_reverse_duration,

        dropoff_datetime = pickup_datetime
            as has_zero_duration,

        total_amount < 0
            as has_negative_total,

        fare_amount < 0
            as has_negative_fare,

        pickup_datetime < dateadd(
            day,
            -1,
            to_date(source_period || '-01')
        )
        or
        pickup_datetime >= dateadd(
            day,
            1,
            dateadd(
                month,
                1,
                to_date(source_period || '-01')
            )
        ) as has_invalid_source_date

    from typed

)

select
    *,

    not (
        has_reverse_duration
        or has_invalid_source_date
    ) as is_valid_for_analysis

from quality