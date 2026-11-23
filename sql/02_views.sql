-- Year on year productivity change per trust.
-- Real resources = cash spend divided by the deflator, so inflation is removed.
CREATE OR REPLACE VIEW vw_trust_productivity AS
WITH yearly AS (
    SELECT
        f.trust_key,
        p.financial_year,
        SUM(f.total_expenditure) / (d.deflator_index / 100) AS real_resources,
        SUM(a.weighted_activity)                             AS activity
    FROM fact_trust_finance f
    JOIN fact_trust_activity a USING (trust_key, period_key)
    JOIN dim_period p          USING (period_key)
    JOIN dim_deflator d        ON d.financial_year = p.financial_year
    GROUP BY f.trust_key, p.financial_year, d.deflator_index
),
changes AS (
    SELECT
        trust_key,
        financial_year,
        real_resources,
        activity,
        -- LAG pulls the previous year for the same trust
        LAG(real_resources) OVER (PARTITION BY trust_key ORDER BY financial_year) AS prev_resources,
        LAG(activity)       OVER (PARTITION BY trust_key ORDER BY financial_year) AS prev_activity
    FROM yearly
)
SELECT
    trust_key,
    financial_year,
    real_resources,
    (real_resources / prev_resources - 1) AS resource_growth,
    (activity / prev_activity - 1)        AS activity_growth,
    -- Productivity growth = activity growth relative to resource growth
    ((activity / prev_activity) / (real_resources / prev_resources) - 1) AS productivity_growth
FROM changes
WHERE prev_resources IS NOT NULL;
