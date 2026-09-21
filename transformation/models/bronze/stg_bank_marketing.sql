select
    age,
    job,
    marital,
    education,
    "default" as has_default,
    balance,
    housing,
    loan,
    day_of_week,
    month,
    duration,
    campaign,
    pdays,
    previous,
    contact,
    poutcome,
    y
from {{ source('raw', 'bank_marketing') }}