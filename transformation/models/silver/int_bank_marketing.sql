select
    cast(age as integer) as age,

    coalesce(nullif(lower(trim(job)), ''), 'unknown') as job,
    coalesce(nullif(lower(trim(marital)), ''), 'unknown') as marital,
    coalesce(nullif(lower(trim(education)), ''), 'unknown') as education,
    coalesce(nullif(lower(trim(has_default)), ''), 'unknown') as has_default,

    cast(balance as numeric) as balance,

    coalesce(nullif(lower(trim(housing)), ''), 'unknown') as housing,
    coalesce(nullif(lower(trim(loan)), ''), 'unknown') as loan,

    cast(day_of_week as integer) as day_of_week,
    lower(trim(month)) as month,

    cast(duration as integer) as duration,
    round(cast(duration as numeric) / 60.0, 2) as duration_minutes,

    cast(campaign as integer) as campaign,
    cast(pdays as integer) as pdays,
    cast(previous as integer) as previous,

    coalesce(nullif(lower(trim(contact)), ''), 'unknown') as contact,
    coalesce(nullif(lower(trim(poutcome)), ''), 'unknown') as poutcome,

    lower(trim(y)) as subscription_status,

    case
        when lower(trim(y)) = 'yes' then true
        when lower(trim(y)) = 'no' then false
        else null
    end as subscribed,

    case
        when pdays = -1 then false
        when pdays >= 0 then true
        else null
    end as previously_contacted

from {{ ref('stg_bank_marketing') }}