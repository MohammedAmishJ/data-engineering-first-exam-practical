select *
from {{ ref('int_bank_marketing') }}
where (subscription_status = 'yes' and subscribed is not true)
   or (subscription_status = 'no' and subscribed is not false)