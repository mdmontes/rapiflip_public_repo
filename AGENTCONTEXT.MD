On session startup, prioritize reading AGENTCONTEXT.MD and AGENTPREFERREDPRACTICES.md. Acknowledge these rules by being concise and avoiding conversational filler when I use native terminal commands

# Project Overview: Real Estate Engine


## Purpose
The Real Estate Engine is a Python-based data processing tool designed to evaluate US national real estate property assessment data for wholesale investors. It leverages Snowflake to query and analyze large-scale property datasets (US_NATIONAL_REAL_ESTATE_PROPERTY__ASSESSMENT_DATA), specifically assessing a property's potential for two primary investment strategies:
1. Buy and Flip: Evaluating deals using the "70% rule" methodology.
<!-- 2. Rental Property: Evaluating feasibility using the "1% rule" methodology. -->

## Tech Stack
- Language: Python 3.11 (PEP 8 Compliant)
- API/Engine: Snowflake Snowpark (Python)
- Framework: FastAPI (Back-end API)
- External APIs: Google Maps (Geocoding), RentCast API (Property Data)
- Data Handling: Pandas
- Environment Management: python-dotenv for secure credential management
- Infrastructure: Snowflake Cloud Data Platform & Docker

## Core Components

```text
real_estate_engine/
├── back_end/
│   ├── __init__.py
│   ├── main.py                     # FastAPI entry point & route definitions
│   ├── find_address/
│   │   ├── __init__.py
│   │   ├── find_address_in_google.py    # Google Geocode API integration
│   │   ├── find_initial_comps.py        # Orchestrates ARV & comparable search
│   │   ├── query_comps_in_radius_snowflake.py # Radius-based SQL search logic
│   │   └── comp_search_logic.py         # Dynamic similarity & ranking logic
│   ├── middleware/
│   │   ├── __init__.py
│   │   ├── session_manager.py           # Snowflake connection pooling & lifespan
│   │   ├── snowflake_log_middleware.py  # Request/Response logging with body capture
│   │   └── event_type_mapper.py         # Dynamic classification of API events
│   └── utils/
│       ├── __init__.py
│       ├── generate_user_report.py      # LLM-based investment report generation
│       ├── log_user_feedback.py         # Logs frontend user feedback to Snowflake
│       ├── system_instructions.md       # AI agent personas and logic rules
│       └── zillow_utils.py              # Zillow search link generation
├── dev_meta/                       # Developer metadata, test scripts, and analysis (excluded from Docker)
│   ├── prompts/                    # LLM instruction history & active tasks
│   ├── sample_schemas/             # Data structure templates for API testing
│   ├── test_data/                  # Mock addresses & saved search results
│   └── test_scripts/               # Standalone SQL & Python validation scripts
├── front_end/
│   ├── english_spanish_dictionary.json # Localization support
│   ├── index.html                  # Main UI structure
│   ├── RapiFlip logo.jpg            # Brand assets
│   ├── script.js                   # Frontend logic & API interaction
│   ├── styles.css                  # UI styling
│   └── tooltips.js                 # UI helper components
├── .dockerignore                   # Docker exclusion rules
├── .env.example                    # Template for environment variables
├── .gitignore                      # Git exclusion rules
├── AGENTCONTEXT.MD                 # Project overview & architectural guide
├── AGENTPREFERREDPRACTICES.md      # Engineering standards & best practices
├── Dockerfile                      # Containerization instructions
├── README.MD                       # Project documentation
├── requirements.txt                # Python dependencies
└── test_connection.py              # Connectivity validation script
```
## Critical Files
- back_end/main.py: The core API server; integrates address parsing and property evaluation logic.
- back_end/utils/generate_user_report.py: Orchestrates LLM calls to generate investment analysis reports.
- back_end/utils/system_instructions.md: Contains the core logic and personas for the AI-driven analysis.
- back_end/utils/zillow_utils.py: Logic for generating non-API Zillow property search links from address strings.
- back_end/middleware/snowflake_log_middleware.py: Intercepts all traffic to log detailed metadata, granular latency metrics, and request bodies to Snowflake for audit and debugging.
- back_end/middleware/session_manager.py: Manages the lifecycle of Snowflake sessions to ensure efficient resource usage.
- back_end/find_address: A modular library of search and valuation logic, separated by responsibility (API vs. Database vs. Calculation).
- AGENTPREFERREDPRACTICES.md: Foundational engineering guidelines for the project.

## Production Level Directory
This tree represents the final directory structure that is packaged into the built Docker container. Development metadata, environment files, test scripts, local virtual environments, and documentation are strictly excluded per `.dockerignore`.

```text
real_estate_engine/
├── back_end/
│   ├── __init__.py
│   ├── main.py
│   ├── find_address/
│   │   ├── __init__.py
│   │   ├── find_address_in_google.py
│   │   ├── find_initial_comps.py
│   │   ├── query_comps_in_radius_snowflake.py
│   │   └── comp_search_logic.py
│   ├── middleware/
│   │   ├── __init__.py
│   │   ├── session_manager.py
│   │   ├── snowflake_log_middleware.py
│   │   └── event_type_mapper.py
│   └── utils/
│       ├── __init__.py
│       ├── generate_user_report.py
│       ├── log_user_feedback.py
│       ├── system_instructions.md
│       └── zillow_utils.py
├── front_end/
│   ├── english_spanish_dictionary.json
│   ├── index.html
│   ├── RapiFlip logo.jpg
│   ├── script.js
│   ├── styles.css
│   └── tooltips.js
├── .dockerignore
├── Dockerfile
└── requirements.txt
```

## Current Capabilities
- Snowpark Integration: Session-based Snowflake connection leveraging secure environment variables.
- Efficient Session Management: Application-level session lifecycle (pre-warming/cleanup) using FastAPI lifespan, ensuring low-latency database interactions.
- FastAPI Backend: A functional REST API with a dedicated endpoint (/api/address) for property search.
- Advanced Address Parsing (Google API): Decoupled Google Geocode API integration for high-precision parsing.
- Multi-Source Verification (RentCast API): Automatically resolves data discrepancies (such as missing square footage) by cross-referencing Snowflake records with RentCast data to maintain high valuation accuracy.
- Resilient Property Search: High success rates on fuzzy address inputs, integrated into a live API workflow.
- Live Property Search: Fuzzy-matched SQL queries against Snowflake PROPS table to retrieve property profiles.
- Integrated Property Sources: Automated generation of direct Zillow search links for target and comparable properties, delivered via the API and hyperlinked in the frontend UI.
- Advanced Request & Latency Logging: Enhanced middleware-driven logging into Snowflake (USER_ACTIVITY table) that captures full request bodies, user metadata, success metrics, and granular latency tracking (Geocoding, DB queries, AI generation).
- Stream-Safe Middleware: Specialized request handling that allows for non-destructive inspection of payloads while preserving data streams for downstream API handlers.
- Dynamic Event Mapping: Automated classification of API events (e.g., APP_ACCESS, ADDRESS_SEARCH_SUCCESS, INFRASTRUCTURE_ERROR).
- Comprehensive Property Metadata: Extraction and calculation of detailed comp attributes, including time since last sale, coordinates, and market valuations.
- User Feedback Capture: A dedicated REST endpoint (`/api/feedback`) that securely logs user feedback alongside detailed request metadata directly into the `USER_FEEDBACK` Snowflake table using parameterized queries.

## Development Status
The project has successfully established a robust, secure backend architecture with high-precision property lookup and sophisticated comparable property search capabilities. Recent updates have solidified the production readiness of the logging system, capturing granular latency metrics to facilitate precise bottleneck identification. Furthermore, the integration of RentCast to patch critical property attributes ensures extreme confidence in final ARV calculations. The engine is fully prepared for integrating these search results into the final valuation logic and expanding the user-facing frontend. Additionally, a robust user feedback loop has been integrated, securely capturing frontend user submissions and request metadata directly into Snowflake to drive continuous improvement.