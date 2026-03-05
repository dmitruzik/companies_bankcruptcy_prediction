# Bankruptcy Prediction Analysis 📊

## Project Overview
This project focuses on predicting company bankruptcy using financial indicators and ratios. The dataset contains comprehensive financial metrics for companies, with the goal of identifying key predictors of bankruptcy and creating actionable insights for risk assessment.

## 🎯 Objectives
- Analyze financial patterns leading to bankruptcy
- Identify key risk indicators and early warning signs
- Create a comprehensive dashboard for monitoring company health
- Develop risk segmentation framework for portfolio management

## 📁 Repository Structure
bankruptcy-prediction/
│
├── datasets/ # All data files
│ ├── raw/ # Original, unmodified data
│ │ └── data.csv # Source dataset with 95+ financial indicators
│ └── processed/ # Cleaned and transformed data
│ └── bankruptcy_analysis_ready.csv
│
├── sql/ # Database setup scripts
│ ├── 01_create_table.sql # Table creation script
│ ├── 02_import_data.sql # Data import commands
│ └── README.md # SQL setup instructions
│
├── analysis/ # Exploratory and statistical analysis
│ ├── 01_exploratory_data_analysis.sql # Initial data exploration
│ ├── 02_correlation_analysis.sql # Correlation with bankruptcy
│ ├── 03_key_metrics_kpi.sql # KPI calculations
│ ├── 04_risk_segmentation.sql # Risk profiling
│ └── README.md # Analysis methodology
│
├── cleaning/ # Data cleaning and preparation
│ ├── 01_data_cleaning.sql # Handle NULLs and inconsistencies
│ ├── 02_handle_outliers.sql # Outlier detection and treatment
│ ├── 03_feature_engineering.sql # Create derived features
│ └── README.md # Data cleaning approach
│
├── dashboards/ # Visualization files
│ ├── bankruptcy_dashboard.pbix # Power BI dashboard
│ ├── bankruptcy_dashboard.twb # Tableau dashboard
│ └── README.md # Dashboard guide
│
└── docs/ # Documentation
├── data_dictionary.md # Column descriptions
├── methodology.md # Analysis methodology
└── insights_report.md # Key findings


## 📊 Dataset Description

The dataset contains financial ratios and indicators for companies, with the target variable being bankruptcy status.

### Key Features:
- **Target Variable**: `Bankrupt?` (1 = Bankrupt, 0 = Healthy)
- **Total Records**: [Your row count]
- **Total Features**: 95+ financial indicators
- **Data Types**: Primarily decimal/numeric values

### Main Categories of Indicators:
1. **Profitability Ratios** (ROA, Operating Margin, Gross Margin)
2. **Liquidity Ratios** (Current Ratio, Quick Ratio)
3. **Leverage Ratios** (Debt Ratio, Debt-to-Equity)
4. **Efficiency Ratios** (Asset Turnover, Inventory Turnover)
5. **Cash Flow Indicators**
6. **Growth Rates**

## 🛠️ Technical Stack

- **Database**: PostgreSQL
- **Query Language**: SQL
- **Analysis Tools**: pgAdmin, SQL
- **Visualization**: Power BI / Tableau
- **Version Control**: Git/GitHub

## 📈 Key Analyses Performed

### 1. Exploratory Data Analysis (EDA)
- Data distribution analysis
- Missing value patterns
- Statistical summaries by bankruptcy status

### 2. Correlation Analysis
- Identification of top predictors of bankruptcy
- Feature importance ranking
- Multicollinearity assessment

### 3. KPI Development
- Portfolio health metrics
- Risk segmentation framework
- Early warning indicators

### 4. Risk Segmentation
- High/Medium/Low risk categories
- Warning flag system
- Critical threshold identification

## 🚀 Getting Started

### Prerequisites
- PostgreSQL 12+
- pgAdmin 4
- Git

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/dmitruzik/compamnies_bankruptcy_prediction.git
   cd companies_bankruptcy-prediction

Key Findings
Top Predictors of Bankruptcy:
ROA (Return on Assets) - Strong negative correlation

Debt Ratio - Strong positive correlation

Current Ratio - Moderate negative correlation

Cash Flow to Sales - Significant negative correlation

Risk Thresholds Identified:
Critical Zone: Current Ratio < 1, Debt Ratio > 80%

Warning Zone: Current Ratio < 1.5, Debt Ratio > 60%

Safe Zone: Current Ratio > 2, Debt Ratio < 40%

📈 Dashboard Features
The dashboard includes:

Portfolio Overview: Overall health metrics

Risk Distribution: Companies by risk category

Key Metrics Comparison: Bankrupt vs Healthy

Watch List: Companies with multiple warning flags

Trend Analysis: Metric distributions

Drill-down Capabilities: Individual company analysis

🤝 Contributing
Feel free to fork this repository and contribute by:

Adding new analysis queries

Improving data cleaning methods

Enhancing visualization techniques

Updating documentation

📝 License
This project is licensed under the MIT License - see the LICENSE file for details.

📧 Contact
For questions or suggestions, please open an issue or contact dmitruz2@meta.ua.


Inspiration: Bankruptcy prediction literature
