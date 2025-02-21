# Base image
FROM python:3.9-slim AS builder

# Set working directory
WORKDIR /app

# Set Default GitHub URL and Allow Overriding
ARG GITHUB_URL=https://raw.githubusercontent.com/ykhaliq2/flask-docker-app/main/
ENV GITHUB_URL=${GITHUB_URL}

# Get necessary files from GitHub
RUN apt-get update && apt-get install -y curl && \
    curl -O ${GITHUB_URL}requirements.txt && \
    curl -O ${GITHUB_URL}app.py && \
    curl -O ${GITHUB_URL}build_and_run.sh

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install Apptainer inside the container
RUN apt-get install -y wget build-essential libseccomp-dev uuid-dev \
    libgpgme-dev squashfs-tools libseccomp2 && \
    wget https://github.com/apptainer/apptainer/releases/download/v1.2.0/apptainer-1.2.0.tar.gz && \
    tar -xzf apptainer-1.2.0.tar.gz && \
    cd apptainer-1.2.0 && \
    ./mconfig && \
    make -C ./builddir && \
    make -C ./builddir install

# Make the script executable
RUN chmod +x /app/build_and_run.sh

# Expose port for Flask
EXPOSE 5000

# Set entrypoint using absolute path
ENTRYPOINT ["/bin/bash", "-c", "/app/build_and_run.sh"]
