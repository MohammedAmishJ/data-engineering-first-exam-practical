select
    job,
    month,
    contact,

    count(*) as total_clients,

    sum(case when subscribed then 1 else 0 end) as subscribed_clients,

    round(
        100.0 * sum(case when subscribed then 1 else 0 end) / count(*),
        2
    ) as subscription_rate,

    round(avg(balance), 2) as average_balance,

    round(avg(duration_minutes), 2) as average_duration_minutes,

    round(avg(campaign), 2) as average_campaign_contacts

from {{ ref('int_bank_marketing') }}

group by
    job,
    month,
    contact