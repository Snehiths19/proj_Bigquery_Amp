# Amplitude Analytics Project

[![dbt CI](https://github.com/Snehiths19/proj_Bigquery_Amp/actions/workflows/dbt-ci.yml/badge.svg)](https://github.com/Snehiths19/proj_Bigquery_Amp/actions/workflows/dbt-ci.yml)

This project addresses a **Customer Segmentation problem** relevant to the **Product Growth**: identifying high-value customers and understanding their journey to improve marketing and product growth strategies. I have performed **RFM Analysis** and prepared data for **Amplitude integration**, where the goal is to utilize Attribution modeling to identify ideal customer journey.

---

## Table of Contents

- [Overview](#overview)
- [Business Problem and Solution](#business-problem-and-solution)
- [Technologies Used](#technologies-used)
- [Data Workflow](#data-workflow)
- [Key Features](#key-features)
- [Data Governance and Testing](#data-governance-and-testing)
- [How to Use](#how-to-use)
- [Visualizations](#visualizations)
- [Project Insights](#project-insights)
- [Future Enhancements](#future-enhancements)
- [Acknowledgments](#acknowledgments)

---

## Overview

This project focuses on:
1. **Analyze Customer Journeys:** Identify patterns in customer interactions with events like `home`, `cart`, and `purchase`.
2. **Segment Customers:** Perform **RFM Analysis** to prioritize customers into categories such as `Champions` and `At-Risk`.
3. **Prepare Data for Amplitude:** Format data for event tracking and analytics to support growth initiatives.

---

## Business Problem and Solution

### **Problem**
The Product Growth team is trying to identify opportunities on which customer journey's to focus on. To achieve this they want to find their most valuable customers and understand which touchpoints drive conversions. This lack of insight results in inefficient marketing spend and missed opportunities for growth.

### **Solution**
This project simulates a workflow tailored to the Product Growth team at Amplitude:
1. [**RFM Analysis:**](https://github.com/Snehiths19/proj_Bigquery_Amp/blob/main/lessons/models/marts/RFM_Segmentation.sql) Categorizes customers into actionable priority groups (e.g., `Champions`, `At-Risk`) to focus efforts on the most valuable users.
2. **Journey Tracking:** Creates a structured dataset for **Amplitude** to provide insights into how customer interactions and traffic sources influence conversions.
3. **Actionable Insights:** Provides a ready-to-use dataset and visualizations to guide marketing and growth decisions. The data is *connected* to Amplitude to utilize its Attribution Modeling and identifying *optimal customer journey* using its Attribution Modeling along with identification.

---

## Technologies Used

- **BigQuery:** For scalable data storage and querying.
- **DBT:** For data transformation, governance, and testing.
- **Pandas:** For flexible data manipulation.
- **Plotly:** For creating interactive visualizations.
- **JupyterLab:** As the interactive development environment.


---

[## Data Workflow] (https://snehiths19.github.io/proj_Bigquery_Amp/)

![DBT lineage](https://github.com/Snehiths19/proj_Bigquery_Amp/blob/main/docs/dbt-dag.png)

1. [**Source Data:**](https://github.com/Snehiths19/proj_Bigquery_Amp/blob/main/lessons/models/staging/stg_ecommerce_events.sql)
   - Customer interactions (`home`, `cart`, `purchase`) with attributes such as `traffic_source` and timestamps.

2. [**RFM Analysis:**](https://github.com/Snehiths19/proj_Bigquery_Amp/blob/main/lessons/models/marts/RFM_Segmentation.sql)
   - Scores users based on **Recency**, **Frequency**, and **Monetary** metrics and assigns them to priority segments.

3. [**Amplitude Integration Prep:**](https://github.com/Snehiths19/proj_Bigquery_Amp/blob/main/lessons/models/marts/Amplitude_events.sql)
   - Structures data into a format ready for Amplitude ingestion with fields like `event_type`, `event_properties`, and `time`.

4. **Visualizations:**
   - Explores customer segments and their interaction paths.

---

## Key Features

- **Customer Segmentation:**
  - Categorizes users into actionable groups based on RFM Analysis.
- **Event Tracking:**
  - Prepares event data for seamless integration with Amplitude.

---

## Data Governance and Testing

To ensure data quality and maintain governance, this project incorporates **dbt** models with robust testing practices.

### **Key Practices**
- **Schema Tests:**
  - **Not Null:** Ensures critical fields like `user_id` and `event_type` are never null.
  - **Unique:** Guarantees the uniqueness of primary keys.
  - **Accepted Values:** Validates that fields contain only predefined values (e.g., RFM categories).
  - **Custom Tests:** Utilizes `dbt_utils` and `dbt_expectations` for additional constraints.

- **Data Governance:**
  - **Version Control:** All dbt models and tests are managed via Git for version tracking.
  - **Documentation:** Each dbt model includes detailed descriptions of tables and columns.
  - **Automated Testing:** Ensures integrity during transformations and protects against data issues.
  - **Naming Conventions:** Maintains consistency across models, columns, and tests.

These practices ensure that the data pipeline is reliable, transparent, and adheres to governance standards.

---

## How to Use

### Prerequisites

- **Python 3.12+** — check with `python --version`
- **Google Cloud SDK (`gcloud`)** — [install instructions](https://cloud.google.com/sdk/docs/install)
- **A GCP project with BigQuery enabled** — note your project ID, you'll need it
- **Read access to `bigquery-public-data.thelook_ecommerce`** (granted to all GCP users by default)

### First-time setup

```powershell
# 1. Clone and enter the repo
git clone https://github.com/Snehiths19/proj_Bigquery_Amp.git
cd proj_Bigquery_Amp

# 2. Create a virtual environment and install dbt
python -m venv venv
venv\Scripts\python.exe -m pip install -r requirements.txt

# 3. Configure your dbt profile
#    The example file in this repo shows the structure with placeholders.
mkdir %USERPROFILE%\.dbt
copy profiles.yml.example %USERPROFILE%\.dbt\profiles.yml
#    Then open %USERPROFILE%\.dbt\profiles.yml and replace `your-gcp-project-id`
#    with your actual GCP project ID.

# 4. Authenticate to BigQuery (opens a browser)
gcloud auth application-default login
gcloud auth application-default set-quota-project your-gcp-project-id

# 5. Verify the connection (run from the dbt project root)
cd lessons
..\venv\Scripts\dbt.exe debug
```

`dbt debug` should report "All checks passed!" — if not, the most common
failure is auth (`invalid_grant`), which means step 4 needs to be re-run.

### Day-to-day commands

All run from inside `lessons/`:

```powershell
..\venv\Scripts\dbt.exe deps       # install packages from packages.yml
..\venv\Scripts\dbt.exe build      # run + test in dependency order (usual default)
..\venv\Scripts\dbt.exe run --select +RFM_Segmentation+  # rebuild one model + deps
..\venv\Scripts\dbt.exe test       # run all tests
..\venv\Scripts\dbt.exe docs generate && ..\venv\Scripts\dbt.exe docs serve
```

See [CLAUDE.md](CLAUDE.md) for the model-layer convention and known open issues.

---
