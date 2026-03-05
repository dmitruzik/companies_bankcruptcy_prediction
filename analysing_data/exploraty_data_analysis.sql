-- SELECT * FROM bankruptcy_prediction
-- LIMIT 5;

-- Exploraty Data Analysis

-- 1. Table overview
SELECT 
    COUNT(*) as total_rows,
    COUNT(DISTINCT bankrupt) as bankrupt_values
FROM bankruptcy_prediction; -- total rows 6819, bancrupt_values 2

-- Get column names and data types
SELECT 
    column_name, 
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'bankruptcy_prediction'
ORDER BY ordinal_position;

-- Check bankruptcy distribution
SELECT 
    bankrupt,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM bankruptcy_prediction
GROUP BY bankrupt;

-- Create a missing values summary
WITH missing_counts AS (
    SELECT 
        COUNT(*) - COUNT(bankrupt) as bankrupt_nulls,
        COUNT(*) - COUNT(roa_c_before_interest_depreciation_before_interest) as roa_c_nulls,
        COUNT(*) - COUNT(roa_a_before_interest_percent_after_tax) as roa_a_nulls,
        COUNT(*) - COUNT(roa_b_before_interest_depreciation_after_tax) as roa_b_nulls,
        COUNT(*) - COUNT(operating_gross_margin) as operating_gross_margin_nulls,
        COUNT(*) - COUNT(realized_sales_gross_margin) as realized_sales_gross_margin_nulls,
        COUNT(*) - COUNT(operating_profit_rate) as operating_profit_rate_nulls,
        COUNT(*) - COUNT(pre_tax_net_interest_rate) as pre_tax_net_interest_rate_nulls,
        COUNT(*) - COUNT(after_tax_net_interest_rate) as after_tax_net_interest_rate_nulls,
        COUNT(*) - COUNT(non_industry_income_expenditure_revenue) as non_industry_income_nulls,
        COUNT(*) - COUNT(continuous_interest_rate_after_tax) as continuous_interest_rate_nulls,
        COUNT(*) - COUNT(operating_expense_rate) as operating_expense_rate_nulls,
        COUNT(*) - COUNT(research_development_expense_rate) as rd_expense_rate_nulls,
        COUNT(*) - COUNT(cash_flow_rate) as cash_flow_rate_nulls,
        COUNT(*) - COUNT(interest_bearing_debt_interest_rate) as interest_bearing_debt_rate_nulls,
        COUNT(*) - COUNT(tax_rate_a) as tax_rate_a_nulls,
        COUNT(*) as total_rows
    FROM bankruptcy_prediction
)
SELECT * FROM missing_counts;


-- Summary statistics for key financial indicators
SELECT 
    'Bankrupt' as metric,
    COUNT(*) as count,
    AVG(bankrupt::int) as mean,
    MIN(bankrupt::int) as min,
    MAX(bankrupt::int) as max,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY bankrupt::int) as median
FROM bankruptcy_prediction

UNION ALL

SELECT 
    'ROA (C)' as metric,
    COUNT(roa_c_before_interest_depreciation_before_interest) as count,
    AVG(roa_c_before_interest_depreciation_before_interest) as mean,
    MIN(roa_c_before_interest_depreciation_before_interest) as min,
    MAX(roa_c_before_interest_depreciation_before_interest) as max,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY roa_c_before_interest_depreciation_before_interest) as median
FROM bankruptcy_prediction

UNION ALL

SELECT 
    'Current Ratio' as metric,
    COUNT(current_ratio) as count,
    AVG(current_ratio) as mean,
    MIN(current_ratio) as min,
    MAX(current_ratio) as max,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY current_ratio) as median
FROM bankruptcy_prediction

UNION ALL

SELECT 
    'Debt Ratio %' as metric,
    COUNT(debt_ratio_percent) as count,
    AVG(debt_ratio_percent) as mean,
    MIN(debt_ratio_percent) as min,
    MAX(debt_ratio_percent) as max,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY debt_ratio_percent) as median
FROM bankruptcy_prediction;


-- OUTLIER DETECTION

-- Create a temporary table to store outlier information
CREATE TEMP TABLE outlier_summary AS
WITH stats AS (
    SELECT 
        'roa_c' as variable,
        AVG(roa_c_before_interest_depreciation_before_interest) as mean,
        STDDEV(roa_c_before_interest_depreciation_before_interest) as stddev,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY roa_c_before_interest_depreciation_before_interest) as q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY roa_c_before_interest_depreciation_before_interest) as q3
    FROM bankruptcy_prediction
    WHERE roa_c_before_interest_depreciation_before_interest IS NOT NULL
)
SELECT 
    variable,
    COUNT(*) as total_values,
    SUM(CASE 
        WHEN roa_c_before_interest_depreciation_before_interest < (q1 - 1.5 * (q3 - q1)) 
         OR roa_c_before_interest_depreciation_before_interest > (q3 + 1.5 * (q3 - q1))
        THEN 1 ELSE 0 
    END) as outliers_iqr,
    SUM(CASE 
        WHEN ABS(roa_c_before_interest_depreciation_before_interest - mean) > 3 * stddev
        THEN 1 ELSE 0 
    END) as outliers_3sigma
FROM bankruptcy_prediction, stats
GROUP BY variable, mean, stddev, q1, q3;

-- View outliers
SELECT * FROM outlier_summary;


-- DATA CLEANING OPERATIONS

-- 1. Handle NULL values (choose appropriate strategy based on your analysis)
-- Option A: Remove rows with too many NULLs
DELETE FROM bankruptcy_prediction
WHERE (
    (CASE WHEN roa_c_before_interest_depreciation_before_interest IS NULL THEN 1 ELSE 0 END +
     CASE WHEN roa_a_before_interest_percent_after_tax IS NULL THEN 1 ELSE 0 END +
     CASE WHEN roa_b_before_interest_depreciation_after_tax IS NULL THEN 1 ELSE 0 END +
     CASE WHEN operating_gross_margin IS NULL THEN 1 ELSE 0 END +
     CASE WHEN realized_sales_gross_margin IS NULL THEN 1 ELSE 0 END +
     CASE WHEN operating_profit_rate IS NULL THEN 1 ELSE 0 END +
     CASE WHEN pre_tax_net_interest_rate IS NULL THEN 1 ELSE 0 END +
     CASE WHEN after_tax_net_interest_rate IS NULL THEN 1 ELSE 0 END) > 5
);

-- 2. Handle outliers (winsorization or capping)
-- Create a cleaned version of the table
CREATE TABLE bankruptcy_prediction_cleaned AS
SELECT 
    bankrupt,
    -- Cap extreme values at 99th percentile
    CASE 
        WHEN roa_c_before_interest_depreciation_before_interest > (
            SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY roa_c_before_interest_depreciation_before_interest) 
            FROM bankruptcy_prediction
        ) THEN (
            SELECT PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY roa_c_before_interest_depreciation_before_interest) 
            FROM bankruptcy_prediction
        )
        WHEN roa_c_before_interest_depreciation_before_interest < (
            SELECT PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY roa_c_before_interest_depreciation_before_interest) 
            FROM bankruptcy_prediction
        ) THEN (
            SELECT PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY roa_c_before_interest_depreciation_before_interest) 
            FROM bankruptcy_prediction
        )
        ELSE roa_c_before_interest_depreciation_before_interest
    END as roa_c_cleaned,
    
    -- Similar for other important columns
    CASE 
        WHEN current_ratio > 10 THEN 10  -- Cap extremely high current ratios
        WHEN current_ratio < 0 THEN 0     -- Floor negative values
        ELSE current_ratio
    END as current_ratio_cleaned,
    
    CASE 
        WHEN debt_ratio_percent > 100 THEN 100  -- Debt ratio can't exceed 100%
        WHEN debt_ratio_percent < 0 THEN 0
        ELSE debt_ratio_percent
    END as debt_ratio_cleaned
    
FROM bankruptcy_prediction;

-- 3. Handle infinite values (if any)
UPDATE bankruptcy_prediction 
SET 
    roa_c_before_interest_depreciation_before_interest = NULL 
WHERE roa_c_before_interest_depreciation_before_interest = 'Infinity'::float 
   OR roa_c_before_interest_depreciation_before_interest = '-Infinity'::float;


-- CORELATION ANALYSIS WITH BANCRUPCY

-- Create a correlation summary with bankruptcy
-- Correlation analysis with bankruptcy using subquery
SELECT 
    feature,
    ROUND(correlation::numeric, 4) as correlation_with_bankruptcy,
    CASE 
        WHEN correlation > 0.3 THEN 'Strong Positive'
        WHEN correlation > 0.1 THEN 'Weak Positive'
        WHEN correlation < -0.3 THEN 'Strong Negative'
        WHEN correlation < -0.1 THEN 'Weak Negative'
        ELSE 'No significant correlation'
    END as interpretation
FROM (
    SELECT
        'ROA (C)' as feature,
        CORR(bankrupt::int, roa_c_before_interest_depreciation_before_interest) as correlation
    FROM bankruptcy_prediction
    UNION ALL
    SELECT
        'Current Ratio',
        CORR(bankrupt::int, current_ratio)
    FROM bankruptcy_prediction
    UNION ALL
    SELECT
        'Debt Ratio %',
        CORR(bankrupt::int, debt_ratio_percent)
    FROM bankruptcy_prediction
    UNION ALL
    SELECT
        'Quick Ratio',
        CORR(bankrupt::int, quick_ratio)
    FROM bankruptcy_prediction
    UNION ALL
    SELECT
        'Net Worth/Assets',
        CORR(bankrupt::int, net_worth_assets)
    FROM bankruptcy_prediction
    UNION ALL
    SELECT
        'Cash Flow to Sales',
        CORR(bankrupt::int, cash_flow_to_sales)
    FROM bankruptcy_prediction
    UNION ALL
    SELECT
        'Operating Profit Rate',
        CORR(bankrupt::int, operating_profit_rate)
    FROM bankruptcy_prediction
    UNION ALL
    SELECT
        'Total Asset Turnover',
        CORR(bankrupt::int, total_asset_turnover)
    FROM bankruptcy_prediction
    UNION ALL
    SELECT
        'Liability to Equity',
        CORR(bankrupt::int, liability_to_equity)
    FROM bankruptcy_prediction
    UNION ALL
    SELECT
        'Cash Flow to Total Assets',
        CORR(bankrupt::int, cash_flow_to_total_assets)
    FROM bankruptcy_prediction
) AS correlations
ORDER BY ABS(correlation) DESC;

-- CLASS IMBALANCE CHECK

SELECT 
    bankrupt,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage,
    SUM(COUNT(*)) OVER() as total
FROM bankruptcy_prediction
GROUP BY bankrupt
ORDER BY bankrupt;


-- CREATE CLEAN TABLE

CREATE TABLE bankruptcy_analysis AS
SELECT 
    bankrupt,
    -- Profitability ratios
    roa_c_before_interest_depreciation_before_interest as roa,
    operating_profit_rate,
    net_income_to_total_assets as return_on_assets,
    
    -- Liquidity ratios
    CASE WHEN current_ratio > 10 THEN 10 ELSE current_ratio END as current_ratio,
    CASE WHEN quick_ratio > 10 THEN 10 ELSE quick_ratio END as quick_ratio,
    
    -- Leverage ratios
    CASE WHEN debt_ratio_percent > 100 THEN 100 ELSE debt_ratio_percent END as debt_ratio,
    liability_to_equity,
    
    -- Efficiency ratios
    total_asset_turnover,
    inventory_turnover_rate_times as inventory_turnover,
    accounts_receivable_turnover,
    
    -- Cash flow indicators
    cash_flow_to_sales,
    cash_flow_to_total_assets,
    
    -- Growth rates
    total_asset_growth_rate,
    operating_profit_growth_rate,
    
    -- Market indicators
    net_value_per_share_a as net_value_per_share,
    revenue_per_share
    
FROM bankruptcy_prediction
WHERE 
    -- Remove rows with critical NULLs
    bankrupt IS NOT NULL
    AND roa_c_before_interest_depreciation_before_interest IS NOT NULL
    AND current_ratio IS NOT NULL
    AND debt_ratio_percent IS NOT NULL;


-- SUMMARY STATISTICS FOR BANKRUPTCY STATUS 

-- Compare statistics between bankrupt and non-bankrupt companies
SELECT 
    bankrupt,
    COUNT(*) as company_count,
    
    -- Profitability
    ROUND(AVG(roa_c_before_interest_depreciation_before_interest)::numeric, 4) as avg_roa,
    ROUND(AVG(operating_profit_rate)::numeric, 4) as avg_operating_profit,
    
    -- Liquidity
    ROUND(AVG(current_ratio)::numeric, 4) as avg_current_ratio,
    ROUND(AVG(quick_ratio)::numeric, 4) as avg_quick_ratio,
    
    -- Leverage
    ROUND(AVG(debt_ratio_percent)::numeric, 4) as avg_debt_ratio,
    ROUND(AVG(liability_to_equity)::numeric, 4) as avg_liability_to_equity,
    
    -- Efficiency
    ROUND(AVG(total_asset_turnover)::numeric, 4) as avg_asset_turnover,
    
    -- Cash flow
    ROUND(AVG(cash_flow_to_sales)::numeric, 4) as avg_cash_flow_to_sales
    
FROM bankruptcy_prediction
GROUP BY bankrupt
ORDER BY bankrupt;
