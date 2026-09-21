select count(*) as row_count
from {{ ref('int_bank_marketing') }}
having count(*) <> 45211