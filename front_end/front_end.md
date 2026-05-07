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