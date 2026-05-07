# RapiFlip

![Python](https://img.shields.io/badge/python-3.11-blue)
![FastAPI](https://img.shields.io/badge/framework-FastAPI-009688)
![Snowflake](https://img.shields.io/badge/data-Snowflake-29B5E8)
![Status](https://img.shields.io/badge/status-active-success)
![License](https://img.shields.io/badge/license-MIT-green)
---

## Public Version Overview

***if interested in accessing proprietary codebase, please reach out to owner!***

RapiFlip is a data engineering application that retrieves, processes, and evaluates property data at scale using Snowflake. It applies custom comparable-property selection logic and investment heuristics to generate actionable insights for real estate investors.

The system exposes its functionality through a FastAPI service and produces structured outputs, including LLM-generated investment reports grounded in retrieved data.

---

## Example Workflow

1. User submits a target property address via the frontend User Interface  
2. Backend:
   - Resolves address discrepancies using Google geocoding API
   - Queries Snowflake Shared Database published by The Warren Group to identify target property records
   - Cross-references target property with RentCast API to clean data discrepancies (e.g., missing Square Footage)
3. Engine:
   - Retrieves nearby comparable properties using sophisticated SQL CTEs against Snowflake Shared Database
   - Applies ranking and filtering logic to identify 5 best comps using calculated weighted average (methodology explained in 'How Comparable Properties Are Scored' below) . 
   - Computes robust 'After Repair Value (ARV)' and returns 5 comps used for calculation
5. Output:
   - Returns structured data + LLM-generated investment report based on target address, comps, and ARV.
   - Logs user activity in Snowflake User Activity Database for production troubleshooting and diagnostics

![RapiFlip Data Flow Diagram](https://lucid.app/publicSegments/view/02885c70-78b0-4d02-9978-ebd8b669780a/image.jpeg)
---

---

## Sample API Response

This response demonstrates how RapiFlip transforms raw property data into structured investment insights, combining deterministic analysis with multilingual LLM-generated explanations.

~~~json
{
  "TARGET_ADDRESS": "924 SOUTH LEXINGTON AVENUE, BURLINGTON, NC 27215",
  "ARV": 173220.53,
  "ARV_PPSF": 206.21,
  "TARGET_ADDRESS_SQFT": 840,
  "LIST_OF_COMPS": [
    {
      "COMP_FULL_ADDRESS": "728 EVERETT ST, BURLINGTON, NC 27215",
      "PRICE_PER_SQFT": 185.18,
      "WEIGHTED_AVG_SCORE": 9.5
    },
    {
      "COMP_FULL_ADDRESS": "506 CENTRAL AVE, BURLINGTON, NC 27215",
      "PRICE_PER_SQFT": 143.33,
      "WEIGHTED_AVG_SCORE": 9.3
    },
    {
      "COMP_FULL_ADDRESS": "601 ACORN ST, BURLINGTON, NC 27215",
      "PRICE_PER_SQFT": 272.55,
      "WEIGHTED_AVG_SCORE": 9.1
    }
  ],
  "USER_REPORT": {
    "english": {
      "investment_thesis": "The ARV is supported by recent comparable sales.",
      "deal_classification": "Good Deal",
      "arv_confidence": "Moderate"
    },
    "spanish": {
      "investment_thesis": "El ARV está respaldado por ventas recientes.",
      "deal_classification": "Buen Negocio",
      "arv_confidence": "Moderada"
    }
  }
}
~~~

---

## How Comparable Properties Are Scored

RapiFlip uses a multi-factor scoring model to identify high-quality comparable properties.  
Each comp is evaluated across five weighted dimensions:

### 1. Proximity (25%)
- < 0.5 miles → highest score  
- Gradually decreases up to ~3 miles  

**Why it matters:**  
Closer properties better reflect local market conditions.

---

### 2. Square Footage Similarity (35%)
- 95%–105% → highest score  
- Expands to 70%–130% range  

**Why it matters:**  
Ensures price-per-square-foot comparisons are meaningful.

---

### 3. Sale Recency (25%)
- Sold within 12 months → full score  

**Why it matters:**  
Captures current market conditions.

---

### 4. Statistical Positioning (10%)
- Based on Z-score of price-per-square-foot  
- Prioritizes comps at or above the cohort mean  

**Why it matters:**  
Prevents undervaluation from distressed or outdated sales, or overvaluation from properties that vastly exceed reasonable home prices.

---

### 5. Flip Probability (5%)
- Based on time between consecutive sales in order to identify comparable properties which might have also been flipped (bought and resold in 12 months or less!).  

**Why it matters:**  
Identifies properties likely reflecting post-renovation value.

---

## Final Scoring Model

~~~text
Weighted Score =
  (Proximity × 0.25) +
  (SqFt Similarity × 0.35) +
  (Recency × 0.25) +
  (Statistical Position × 0.10) +
  (Flip Probability × 0.05)
~~~

---

## Why Z-Score ≥ 0 Is Enforced

RapiFlip filters out properties with a negative Z-score (below the cohort mean price per square foot).

This is a deliberate design decision:

- Below-average comps often represent:
  - Distressed properties  
  - Unrenovated homes  
  - Non-market transactions  

- Including these would:
  - Artificially suppress ARV estimates  
  - Introduce downward bias into valuation  

By enforcing `Z-score ≥ 0`, the system ensures:
- ARV reflects **market-supported or improved property values**
- Comparable selection aligns with **investor exit pricing**, not acquisition anomalies

This constraint is critical for maintaining **valuation integrity in flip-based analysis**.

---
## Data Integrity: Multi-Source Verification

RapiFlip prioritizes data accuracy by implementing a failover and verification layer for critical property attributes.

- **RentCast API Integration:** When Snowflake property records contain incomplete or conflicting square footage data, the system automatically queries the RentCast API to patch the record.
- **Valuation Reliability:** Since Square Footage is a primary driver of the Price Per Square Foot (PPSF) metric, this multi-source approach ensures that ARV estimates are grounded in the most reliable data available.

---

## Observability: Granular Latency Tracking

The system includes custom middleware designed for deep observability into the request lifecycle. Every API call is logged to Snowflake with a breakdown of internal process durations:

- **Geocoding Latency:** Time spent resolving addresses via Google Maps.
- **Database Latency:** Time spent establishing Snowflake connections and executing complex SQL queries.
- **AI Generation Latency:** Time spent generating bilingual investment reports via Gemini.
- **End-to-End Latency:** Total request duration as perceived by the client.

This telemetry allows for precise bottleneck identification and performance optimization across the entire data pipeline.

## Problem Context & Impact

Access to reliable real estate investment analysis tools is unevenly distributed.

Many independent investors—particularly within Spanish-speaking communities—face barriers when trying to:
- Interpret comparable property data (“comps”)
- Accurately estimate ARV
- Apply standardized investment heuristics
- Navigate tools that are often English-only or cost-prohibitive

RapiFlip addresses this by:
- Automating comp discovery and evaluation  
- Standardizing investment analysis  
- Providing multilingual outputs (English/Spanish)  
- Abstracting complex data pipelines behind a simple API  

The goal is to make **institutional-grade analysis accessible to individual investors**.

---

## Tech Stack

- Gemini CLI
- Python 3.11  
- FastAPI  
- Snowflake (Snowpark)  
- RentCast API
- Pandas  
- Docker
- Render.com  

---

## Design Principles

- Deterministic Core, Generative Layer  
- Separation of Concerns  
- Accessibility by Design  
- Production-Aware Logging & Observability  

---

## Getting Started

To run locally, the following is required:

1. Valid Snowflake account and proper mounting of the Warren Groups's shared database via the Snowflake Marketplace. Proper RBAC controls must be enabled for the role and warehouse established in .env
2. Valid Google Account with API Keys to:
   - Google Geocoding API
   - Gemini GenAI Models
3. Valid RentCast account with API Keys 
4. Creation of User Logs Database, Schema, and table in order for middleware to log user activity

~~~bash
git clone https://github.com/yourusername/rapiflip.git
pip install -r requirements.txt
cp .env.example .env
uvicorn back_end.main:app --reload
~~~

