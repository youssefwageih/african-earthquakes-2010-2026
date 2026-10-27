# 🌍 African Earthquakes Analysis (2010–2026)

![SQL](https://img.shields.io/badge/SQL-PostgreSQL-336791?style=flat&logo=postgresql&logoColor=white)
![Excel](https://img.shields.io/badge/Microsoft_Excel-Data_Cleaning-217346?style=flat&logo=microsoft-excel&logoColor=white)
![Power BI](https://img.shields.io/badge/Power_BI-Dashboard-F2C811?style=flat&logo=powerbi&logoColor=black)
![Data Source](https://img.shields.io/badge/Source-USGS_Catalog-00599C?style=flat)

### 📌 Why This Project Exists (The "Did My Chair Just Move?" Moment)
If you live in Egypt, you know the exact routine over the past few years: you're sitting quietly at your desk, your coffee cup ripples, the chandelier sways for three seconds, and everyone immediately rushes to social media to ask, *"Did anyone else feel that, or do I just need sleep?"*

Behind that relatable moment is a very real, lingering generational memory. Anyone who lived through—or grew up hearing stories about—the **1992 Cairo earthquake** knows how devastating a sudden tremor can be for families, old neighborhoods, and everyday infrastructure. Feeling more frequent tremors lately made me wonder: **Is seismic activity across Africa actually speeding up, or are we just paying more attention?**

Instead of guessing, I pulled 16 years of raw geological sensor data from the **United States Geological Survey (USGS)** (2010 through Q3 2026) and built an end-to-end pipeline using **Excel, PostgreSQL, and Power BI**. The goal: map where the ground is shifting most, understand how deep these quakes really are, and investigate the massive spike in East African tremors alongside the construction and filling of the **Grand Ethiopian Renaissance Dam (GERD)**.

---

## 🖼️ Dashboard Preview
*(Insert your Power BI Dashboard screenshot or GIF here)*

---

## 🛠️ Tech Stack & Workflow
* **Data Source:** USGS Earthquake Hazards Program (ComCat Catalog)
* **Data Cleaning & Preprocessing:** Microsoft Excel & SQL (PostgreSQL)
* **Exploratory Data Analysis (EDA):** PostgreSQL (Aggregations, Time-Series Trends, Spatial Filtering, Window Functions & Subqueries/CTEs)
* **Data Visualization:** Microsoft Power BI

---

## 📥 1. Getting the Data (And Drawing the Borders)
* **The Raw Pull:** Extracted 16+ years of historical seismic logs (`2010-01-01` to `Q3 2026`) from the USGS Earthquake Catalog.
* **The Geographic Focus:** Applied latitude and longitude bounding-box filters to capture the African continent and its active fault lines—specifically the **East African Rift System (EARS)**, the **Main Ethiopian Rift**, and the **North African Mediterranean boundary**.
* **Core Signals Tracked:**
  * `time` — Exact UTC timestamp (when the tremor hit).
  * `latitude` & `longitude` — Epicenter coordinates.
  * `depth` & `mag` — How deep the rupture started and how hard it hit.
  * `place` — Nearest town/region description from the sensor.

---

## 🧹 2. Taming the Mess: Data Cleaning & Transformation
Global seismic sensors are great at detecting shockwaves, but terrible at spelling and geography. Before running a single chart, the raw logs needed serious cleanup in Excel and PostgreSQL:

* **Evicting the Uninvited Guests (Border Filtering):**
  * A rectangular coordinate box around Africa inevitably drags in neighbors.
  * Filtered out Southern European islands and Mediterranean spillover, as well as West Asian records (Saudi Arabia, Yemen, etc.) so African regional totals stayed 100% accurate.
* **Handling Ghosts in the Machine (`NULL` Audit):**
  * Audited critical columns (`mag`, `depth`, `latitude`, `longitude`, `place`, `Country`) for blanks and nulls.
  * Dropped incomplete sensor misfires where missing coordinates or magnitudes would warp map visuals or skew regional averages.
* **Teaching SQL Some Manners (String Standardization):**
  * Sensor descriptions came in every casing imaginable (`ethiopia`, `ETHIOPIA`, `Ethiopia ` with trailing spaces). Left alone, SQL treats those as three different countries.
  * Used `UPPER`, `LOWER`, `INITCAP` / `PROPER`, and `TRIM` to standardize region names, country labels, and magnitude types (`magType`)—guaranteeing clean `GROUP BY` aggregations and tidy Power BI slicers.
* **Feature Engineering (Turning Numbers into Context):**
  * **Time Buckets:** Parsed UTC timestamps into clean `Year`, `Quarter`, and `Month` fields to track year-over-year acceleration.
  * **Magnitude Tiers:** Grouped raw Richter values into human-readable tiers (*Light*, *Moderate*, *Strong*, *Major*).
  * **Focal Depth Zones:** Classified quakes into **Shallow (< 70 km)**, **Intermediate (70–300 km)**, and **Deep (> 300 km)**—because a moderate quake right beneath the surface does far more damage to a town than a stronger one 300 km underground.

---

## 🔍 3. Key Findings & What the Data Tells Us
*(Note: Replace `[ placeholders ]` with your exact dashboard numbers before publishing)*
* **The East African Surge:** Ethiopia emerged as the highest-frequency seismic hotspot in the dataset, showing a sharp surge in annual earthquake counts coinciding directly with the construction and multi-stage reservoir filling of the **GERD**.
* **The Shallow-Quake Problem:** Over `[X]%` of recorded African tremors occurred in the **Shallow zone (< 70 km)**. Shallow tremors don't have room to dissipate underground, meaning even moderate magnitudes hit surface communities hard.
* **North African Tremors:** While the Mediterranean boundary experiences fewer total events than the East African Rift, tremors there frequently ripple into densely populated coastal and Nile Delta cities.

---

## 🏗️ 4. Beyond the Dashboard: Practical Solutions for Vulnerable Communities
Data analysis shouldn't stop at a pretty map. When you look at *where* these shallow earthquakes are multiplying—often across rapidly growing towns and rural areas in the East African Rift and North Africa—the human stakes become obvious. 

Most developing municipalities cannot afford billion-dollar Japanese-style skyscraper dampers, deep seismic pilings, or specialized high-rise structural engineering teams. Expecting cash-strapped local economies to build earthquake-proof high-rises is unrealistic. Instead, resilience has to match local economic and infrastructural realities:

1. **Cap New Construction at 3 to 4 Stories in Active Rift Zones:**
   * High-rise buildings require complex engineering, strict steel-reinforcement inspections, and expensive maintenance to survive repeated ground shaking. 
   * In emerging towns without heavy regulatory oversight or capital, enforcing a **strict 4-story maximum** drastically lowers structural weight and reduces the risk of catastrophic "pancake" collapses that trap hundreds of residents.
2. **Build Out, Not Up (Low-Density Spatial Planning):**
   * Dense, tightly packed vertical neighborhoods turn a single building failure into a domino effect and block ambulances and rescue equipment with rubble.
   * Encouraging **spread-out, low-rise urban layouts** with wider street setbacks creates natural safety buffers between homes and keeps evacuation corridors open when shallow (< 70 km) tremors strike.
3. **Affordable "Confined Masonry" Over Expensive High-Tech Engineering:**
   * Local builders don't need aerospace budgets to make a 2-to-4-story building safer. Simple, low-cost interventions—like adding **reinforced concrete ring beams** (tie-beams) at each floor level and around door/window frames—hold brick and block walls together during horizontal shaking at a fraction of the cost of high-rise engineering.
4. **Independent Reservoir-Induced Seismicity (RIS) Monitoring:**
   * Given the clear visual correlation between mega-dam filling phases and regional tremor spikes, mega-infrastructure projects across Africa should pair reservoir filling schedules with open-data seismic monitoring—slowing down water-loading phases when local fault stress spikes.
5. **SMS & Siren Early-Warning Networks:**
   * Even 15 to 30 seconds of warning before secondary seismic waves arrive allows families in low-rise buildings to walk straight outside into open streets—turning a potential tragedy into a manageable evacuation.
