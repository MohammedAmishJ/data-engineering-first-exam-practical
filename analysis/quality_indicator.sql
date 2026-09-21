select
    count(*) as total_records,
    count(*) filter (where y = 'yes') as subscribed_records,
    round(
        100.0 * count(*) filter (where y = 'yes') / count(*),
        2
    ) as subscription_rate
from raw.bank_marketing;