select *
from {{ ref('int_bank_marketing') }}
where age < 18
   or age > 100