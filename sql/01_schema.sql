-- Star schema for the trust productivity project.
-- Run once on an empty MySQL database.

-- Dimension: one row per trust, with attributes used for grouping and controls
CREATE TABLE dim_trust (
    trust_key        INT PRIMARY KEY AUTO_INCREMENT,
    trust_code       VARCHAR(10)  NOT NULL,      -- official organisation code
    trust_name       VARCHAR(200) NOT NULL,
    trust_type       VARCHAR(50),                -- acute, specialist, teaching, and so on
    region           VARCHAR(50),
    hosts_shared_services BOOLEAN DEFAULT FALSE  -- flag for data recording distortions
);

-- Dimension: financial year and month so like for like periods can be compared
CREATE TABLE dim_period (
    period_key       INT PRIMARY KEY,
    financial_year   VARCHAR(7),                 -- for example 2025/26
    month_number     TINYINT,                    -- 1 = April
    period_start     DATE
);

-- Deflator used to convert cash spending into real terms
CREATE TABLE dim_deflator (
    financial_year   VARCHAR(7) PRIMARY KEY,
    deflator_index   DECIMAL(10,4)               -- base year = 100
);

-- Trust lineage so mergers and splits do not break year on year comparisons
CREATE TABLE dim_trust_lineage (
    old_trust_code   VARCHAR(10),
    new_trust_code   VARCHAR(10),
    effective_date   DATE,
    PRIMARY KEY (old_trust_code, new_trust_code, effective_date)
);

-- Fact: resources used by each trust in each period
CREATE TABLE fact_trust_finance (
    trust_key         INT,
    period_key        INT,
    total_expenditure DECIMAL(18,2),
    pay_expenditure   DECIMAL(18,2),             -- lets pay driven growth be separated
    PRIMARY KEY (trust_key, period_key)
);

-- Fact: weighted activity delivered by each trust in each period
CREATE TABLE fact_trust_activity (
    trust_key         INT,
    period_key        INT,
    weighted_activity DECIMAL(18,2),             -- cost weighted so specialties are comparable
    PRIMARY KEY (trust_key, period_key)
);

-- Fact: waiting time outcomes, used to link productivity to patient impact
CREATE TABLE fact_trust_waits (
    trust_key         INT,
    period_key        INT,
    waiting_list_size INT,
    pct_within_18_weeks DECIMAL(5,2),
    pct_cancer_within_target DECIMAL(5,2),
    PRIMARY KEY (trust_key, period_key)
);
