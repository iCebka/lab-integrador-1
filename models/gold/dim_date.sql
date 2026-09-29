with dates as (

    select
        pickup_datetime::date as date_day
    from {{ ref('slv_yellow_taxi_trips') }}

    union

    select
        dropoff_datetime::date as date_day
    from {{ ref('slv_yellow_taxi_trips') }}

)

select
    to_number(
        to_char(date_day, 'YYYYMMDD')
    ) as date_key,

    date_day,

    year(date_day) as year,
    quarter(date_day) as quarter,
    month(date_day) as month_number,
    day(date_day) as day_of_month,

    dayofweekiso(date_day) as day_of_week,

    case
        when dayofweekiso(date_day) in (6, 7)
            then true
        else false
    end as is_weekend

from dates