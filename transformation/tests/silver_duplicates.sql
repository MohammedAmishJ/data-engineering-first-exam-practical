with numbered as (
    select
        *,
        row_number() over (
            partition by
                age,
                job,
                marital,
                education,
                has_default,
                balance,
                housing,
                loan,
                day_of_week,
                month,
                duration,
                campaign,
                pdays,
                previous,
                contact,
                poutcome,
                subscription_status
            order by age
        ) as row_num
    from {{ ref('int_bank_marketing') }}
)

select *
from numbered
where row_num > 1