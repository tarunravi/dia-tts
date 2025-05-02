# Base image with PyTorch and CUDA support
FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-devel

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install only required system packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends libsndfile1 ffmpeg git && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Python dependencies and Dia (without re-installing torch)
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir git+https://github.com/nari-labs/dia.git --no-deps

# Copy application code
COPY . .

# Expose Flask port
EXPOSE 5023

# Launch with Gunicorn for multiple workers
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5023", "app:app"]