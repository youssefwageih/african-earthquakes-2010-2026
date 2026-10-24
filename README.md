# 🌍 African Earthquakes Analysis (2010–2026)

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-336791?style=flat&logo=postgresql&logoColor=white)
![Excel](https://img.shields.io/badge/Microsoft_Excel-Data_Cleaning-217346?style=flat&logo=microsoft-excel&logoColor=white)
![Power BI](https://img.shields.io/badge/Power_BI-Dashboard-F2C811?style=flat&logo=powerbi&logoColor=black)
![Data Source](https://img.shields.io/badge/Source-USGS_Catalog-00599C?style=flat)

## 📌 Project Overview
An end-to-end data analysis project examining **16 years of seismic activity across the African continent (2010–2026)**. Using **Excel**, **SQL (PostgreSQL)**, and **Power BI**, this project transforms raw geological records from the **United States Geological Survey (USGS)** into actionable insights on geographic hotspots, focal depth patterns, and a **spotlight investigation into the exponential surge of earthquakes in East Africa alongside the construction and filling of the Grand Ethiopian Renaissance Dam (GERD)**.

### 🖼️ Dashboard Preview
> 

---

## 🛠️ Tech Stack & Workflow
* **Data Source:** USGS Earthquake Hazards Program (ComCat Catalog)
* **Data Cleaning & Preprocessing:** Microsoft Excel & SQL (PostgreSQL)
* **Exploratory Data Analysis (EDA):** SQL (aggregations, time-series trends, spatial filtering, window functions and CTEs)
* **Data Visualization:** Microsoft Power BI

---

## 📥 1. Data Gathering Process (USGS)
* **Source Extraction:** Extracted historical seismic event records (`2010-01-01` to `Q3 of 2026`) from the **USGS Earthquake Catalog**.
* **Geographic Scope:** Filtered records across the African continent through the longtitude and the latitude Advanced filters and adjacent fault boundaries, with a primary focus on the **East African Rift System (EARS)**, the **Main Ethiopian Rift**, and the **North African Mediterranean boundary**.
* **Core Attributes Collected:**
  * `time` — Exact UTC timestamp of the seismic event.
  * `latitude` & `longitude` — Epicenter geographic coordinates.
  * `place` — Nearest geographic region and country identifier.

---

## 🧹 2. Data Cleaning & Transformation
Raw seismic logs from global sensors contain inconsistent formatting, missing measurements, and non-standardized location strings. The dataset was cleaned prior to analysis using **Excel** and **SQL**:

* **Removing Empty & Incomplete Rows:**
* * Audited the dataset for `NULL` and blank values across critical columns (`mag`, `depth`, `latitude`, `longitude`, `place`, and `Country`).
* * Removed incomplete sensor entries where missing magnitude or coordinate data would skew regional frequency trends and map visuals.
* **Removed the non African Countries and Regions:**
* *Removed South European Countries and Islands that intersect with African Borders
* *Removed West Asians Countries like Saudi, Yemen, etc...
* **Unifying Letter Casing & String Standardization:**
  * Standardized inconsistent text across region names, country labels, and magnitude types (`magType`) using text functions (`UPPER`, `LOWER`, `INITCAP` / `PROPER`, and `TRIM`).
  * Eliminated duplicate grouping anomalies caused by mixed casing (e.g., unifying variations like `ethiopia`, `ETHIOPIA`, and `Ethiopia`) to ensure accurate `GROUP BY` aggregations in SQL and clean slicers in Power BI.
* **Feature Extraction & Categorization:**
  * Parsed UTC timestamps into standardized `Year`, `Quarter`, and `Month` columns to track year-over-year growth rates.
  * Extracted clean **Country** names from raw USGS `place` strings.
  * Classified events into **Magnitude Tiers** (*Light, Moderate, Strong, Major*) and **Depth Zones** (*Shallow: under 70 km, Intermediate: 70–300 km, Deep: over 300 km*).
