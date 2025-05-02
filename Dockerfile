# Use a PyTorch image with CUDA support
FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-devel

# Avoid interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC

# Install system dependencies
RUN apt-get update && \
    apt-get install -y -qq tzdata libsndfile1 ffmpeg git && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt ./
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy application code
COPY . .

# Expose port for Flask (5023)
EXPOSE 5023

# Run with Gunicorn for concurrency, listening on 5023
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5023", "app:app"]