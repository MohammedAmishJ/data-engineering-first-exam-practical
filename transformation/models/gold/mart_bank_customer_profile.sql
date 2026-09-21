select
    job,
    marital,

    count(*) as total_clients,

    sum(case when subscribed then 1 else 0 end) as subscribed_clients,

    round(
        100.0 * sum(case when subscribed then 1 else 0 end) / count(*),
        2
    ) as subscription_rate,

    round(avg(age), 2) as average_age,

    round(avg(balance), 2) as average_balance

from {{ ref('int_bank_marketing') }}

group by
    job,
    marital