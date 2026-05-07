# Agent Preferred Practices

This document outlines the engineering standards and best practices adopted for the Real Estate Engine project.

## 1. Environment Configuration & Security
- **No Hardcoding:** Sensitive credentials (passwords, accounts) and environment-specific details (database names, schemas, tables) must never be hardcoded in the source code.
- **Environment Variables:** All configuration must be loaded from a `.env` file using `python-dotenv`.
- **Credential Protection:** `.env` files and other sensitive configuration files must be included in `.gitignore` to prevent them from being committed to version control.
- **Example Files:** Provide a `.env.example` file with placeholder values to guide other developers on required configuration without exposing secrets.
- **Gemini CLI authentication:** Gemini CLI should access my `GEMINI_API_KEY` from my `.env` files.

## 2. Snowflake & Snowpark Best Practices
- **Session Management:** Always use `try...finally` blocks or context managers to ensure Snowpark sessions are closed properly, even if errors occur.
- **Persistent Sessions:** For cross-functional session management, use `get_snowflake_session()` from `back_end/middleware/session_manager.py`. This utility provides a pre-warmed, heartbeat-validated session that is managed across the application lifecycle.
- **Identifier Handling:** When referencing database objects (tables, columns), leverage environment variables to maintain flexibility across different Snowflake environments.
- **Resource Efficiency:** Use selective queries and chunking when performing large-scale metadata analysis (e.g., calculating null percentages across hundreds of columns) to avoid hitting SQL expression limits.

## 3. Data Dictionary & Schema Analysis
- **User-Centric Documentation:** Translate technical column names into "Regular Column Names" that are understandable by non-technical users.
- **Enriched Metadata:** Always include descriptive details and data quality metrics (like Percentage of Null Values) to provide a comprehensive view of the dataset.
- **Persistence:** Save analysis results in standardized formats (e.g., CSV) within designated `data-analysis/` folders for easy access.

## 4. SQL Injection & Security
- **No Direct Variable Interpolation:** Never use f-strings, `%` formatting, or string concatenation to build SQL queries with user-provided data.
- **Parameterized Queries:** Always use bind variables (`?` for Snowpark) to pass data to SQL commands. Example: `session.sql("SELECT * FROM table WHERE col = ?", params=[val])`.
- **Snowflake Functions & Bind Parameters:** Be aware that Snowflake's `VALUES` clause is restrictive. When applying functions like `PARSE_JSON()` to bind parameters, use the `INSERT ... SELECT` pattern instead of `INSERT ... VALUES`.
- **Trusted Identifiers:** F-strings are ONLY permitted for database, schema, and table identifiers that are loaded from trusted internal configuration (e.g., `.env`). These identifiers cannot be parameterized.

## 5. Source Control & Repository Health
- **Git Hygiene:** Maintain a clean `.gitignore` that excludes virtual environments (`venv/`), temporary files, and OS-specific metadata (e.g., `.DS_Store`). 
- **dev_meta Folder:** The `dev_meta/` directory is used to house developer scripts, test data, and analysis. Unlike typical metadata folders, `dev_meta/` **must be committed** to the repository (ensure it is NOT in `.gitignore`). However, it must be included in `.dockerignore` to prevent it from being included in production builds.
- **Context Awareness:** Keep `AGENTCONTEXT.MD` updated to provide a clear entry point for new agents or developers joining the project.

## 6. Deployment Standards
- **Latest Deployment Branch:** The `deployment_setup` branch is the current standard for deploying the application to the development environment on render.com. 
- **Production Exclusion:** Ensure that development-only files (like those in `dev_meta/`) are excluded from the Docker image as specified in `.dockerignore`.

## 7. Modularity Guidelines
- **Logic Segregation:** Ensure all logic is modular, avoiding excessively long modules. If a script or module becomes increasingly long, extract the excess logic into a separate Python file that can be instantiated and called via a function.
