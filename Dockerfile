# Use an official lightweight Python image
FROM python:3.10-slim

# Set the working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install git
RUN apt-get update && apt-get install -y git

# Install DIA library from GitHub
RUN pip install git+https://github.com/nari-labs/dia.git

# Copy application code
COPY . .

# Set environment variables for Flask
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0

# Expose port 5023
EXPOSE 5023

# Run the Flask app
CMD ["gunicorn", "-b", "0.0.0.0:5023", "--workers", "1", "--preload", "app:app"]
