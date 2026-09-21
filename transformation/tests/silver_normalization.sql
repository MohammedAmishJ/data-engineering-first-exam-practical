select *
from {{ ref('int_bank_marketing') }}
where job <> lower(trim(job))
   or marital <> lower(trim(marital))
   or education <> lower(trim(education))
   or has_default <> lower(trim(has_default))
   or housing <> lower(trim(housing))
   or loan <> lower(trim(loan))
   or month <> lower(trim(month))
   or contact <> lower(trim(contact))
   or poutcome <> lower(trim(poutcome))
   or subscription_status <> lower(trim(subscription_status))