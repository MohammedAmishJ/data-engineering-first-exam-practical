select *
from {{ ref('int_bank_marketing') }}
where day_of_week < 1
   or day_of_week > 31
   or duration < 0
   or duration_minutes < 0
   or campaign < 1
   or pdays < -1
   or previous < 0