select
    raw_record,

    _source_file as source_file,
    _source_row_number as source_row_number,

    replace(
        regexp_substr(_source_file, '[0-9]{4}/[0-9]{2}'),
        '/',
        '-'
    ) as source_period,

    _ingested_at as loaded_at

from {{ source('raw', 'yellow_taxi_trips') }}