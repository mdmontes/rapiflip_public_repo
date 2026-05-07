# 1. Use a lightweight Python base image
FROM python:3.11-slim

# 2. Set the working directory inside the container
WORKDIR /app

# 3. Install system dependencies if needed 
# (Required for some Snowflake/Network libraries on slim images)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 4. Copy and install Python dependencies
# We copy this first to take advantage of Docker's layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy the Application code and UI
# We copy only the folders needed for the app to run
COPY back_end/ ./back_end/
COPY front_end/ ./front_end/

# 6. Expose the port FastAPI runs on
EXPOSE 8000

# 7. Start the application
# We use back_end.main:app because main.py is inside the back_end folder
CMD ["uvicorn", "back_end.main:app", "--host", "0.0.0.0", "--port", "8000"]