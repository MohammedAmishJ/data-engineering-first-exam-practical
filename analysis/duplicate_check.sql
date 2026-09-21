with numbered as (
    select
        *,
        row_number() over (
            partition by
                age,
                job,
                marital,
                education,
                "default",
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
                y
            order by _dlt_id
        ) as row_num
    from raw.bank_marketing
)

select count(*) as duplicate_records
from numbered
where row_num > 1;