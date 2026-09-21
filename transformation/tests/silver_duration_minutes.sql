select *
from {{ ref('int_bank_marketing') }}
where duration_minutes <> round(cast(duration as numeric) / 60.0, 2)