EXPLAIN ANALYZE
SELECT
    job,
    COUNT(*) AS total_clients,
    AVG(balance) AS average_balance
FROM raw.bank_marketing
GROUP BY job;