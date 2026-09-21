select
    count(*) filter (where age is null) as age_missing,
    count(*) filter (where job is null) as job_missing,
    count(*) filter (where marital is null) as marital_missing,
    count(*) filter (where education is null) as education_missing,
    count(*) filter (where balance is null) as balance_missing,
    count(*) filter (where y is null) as target_missing
from raw.bank_marketing;