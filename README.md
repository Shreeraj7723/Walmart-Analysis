# 🛒 Walmart Retail Sales Analytics & Forecasting
## End-to-End Data Analytics Project (Python • SQL • ML • Power BI)



### 📌 Overview

This is a complete retail analytics project built using Python, SQL, Machine Learning, and Power BI.
It simulates a real corporate data pipeline — from cleaning raw datasets → engineering features → building ML models → SQL business insights → a professional Power BI dashboard.

### 🚀 Project Goals

Analyze Walmart sales performance across stores, departments, and seasons

Forecast weekly sales using ML models

Understand economic drivers (CPI, Fuel Price, Unemployment, Temperature)

Build automated SQL logic (CTEs, Views, Stored Procedures, Triggers)

Deliver an executive-friendly Power BI dashboard with Smart Narrative

### 📂 Repository Structure
Walmart-Retail-Analytics/
│
├── data/                # Raw & cleaned datasets
├── notebooks/           # Python notebooks (EDA + ML)
├── sql/                 # All SQL scripts (CTEs, Views, SPs, Triggers)
├── powerbi/             # Power BI dashboard (.pbix)
└── README.md            # Documentation

### 🧠 Technologies Used
🔹 Data Engineering & Analysis

Python (Pandas, NumPy, Matplotlib, Scikit-learn, XGBoost)

🔹 Database & Business Logic

MySQL (Joins, CTEs, Window Functions, Stored Procedures, Views, Triggers)

🔹 Business Intelligence

Power BI (Star Schema, DAX, YoY, Rolling Averages, Smart Narrative)

### 🧪 Python: Data Processing & Machine Learning
✔ Key Steps

Cleaned and merged Train, Stores, Features, Test tables

Handled missing values

Engineered:

Date features (Year, Month, Week, Quarter)

Markdown totals

Store categories

Rolling averages

Lag features

Encoded categorical variables

Trained ML models (Linear Regression, Extra Trees, XGBoost)

### 📊 ML Model Performance
Model	RMSE
Linear Regression	~21,786
Extra Trees	~7,910
XGBoost	~4,556 (Best)

### 🧮 SQL: Business Insights & Automation
✔ Concepts Implemented

JOINs, Aggregations

CTEs

Window Functions (ROW_NUMBER, RANK, LAG)

Views

Stored Procedures

Triggers

Audit Logs

#### ✔ SQL Deliverables
📌 Views

vw_walmart_full → Master fact table

vw_store_sales_summary → Yearly KPIs

📌 Stored Procedures

get_store_performance(store_id)

compare_stores(store1, store2)

📌 Triggers

Prevent inserting negative weekly sales

Log all new sales inserts into sales_audit_log

### 📊 Power BI: Dashboard & Reporting
✔ Data Model (Star Schema)

FactSales (From SQL view)

DimStore

DimDate (via Power Query)

✔ DAX Measures

Total Sales

Avg Weekly Sales

YoY Sales

YoY Growth %

Holiday vs Non-Holiday Sales

Time Intelligence Functions

✔ Dashboard Pages

Executive Summary

Store Performance

Department Insights

Economic Drivers

Holiday Impact & Seasonality

Smart Narrative Summary (auto-insights)

📈 Key Business Insights

$6.74B Total Sales

42.22% YoY Growth

Store Type A leads with $4.3B

Store 20 is top performer (~$301M)

Holidays create clear revenue spikes

CPI & Fuel Price ↑ → slight drop in sales

Medium unemployment areas have best performance

Larger stores outperform smaller formats

## 💡 Challenges Faced

Handling large datasets in Python & SQL

Importing large CSVs into MySQL

Aligning dates across tables

Fixing LabelEncoder mismatches for test data

Troubleshooting YoY & Holiday DAX

Designing clean dimension–fact relationships

## 🎯 Learnings

End-to-end data pipeline design

Feature engineering for ML forecasting

Advanced SQL (CTEs, window functions, triggers)

Star schema modeling in BI

Developing executive dashboards

Time intelligence & DAX mastery

Automated narrative storytelling

## 📁 Project Files

🧪 Python Notebook (EDA, ML)

🗄 SQL Scripts (Analysis, Views, Procedures, Triggers)

📊 Power BI Dashboard (.pbix)

📁 Clean Data Files

## 🤝 Connect
Author: Shreerajsingh Chouhan
Linkedin: Shreerajsingh.C. Chouhan
If you'd like to see the dashboard or discuss the workflow, feel free to reach out!
Happy to share learnings, code, and insights 😊
