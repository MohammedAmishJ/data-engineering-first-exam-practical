select *
from {{ ref('int_bank_marketing') }}
where (pdays = -1 and previously_contacted is not false)
   or (pdays >= 0 and previously_contacted is not true)