# Dockerfile
FROM nvidia/cuda:12.6.2-cudnn-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive

# Base system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.12 python3-pip python3.12-venv \
    git curl ca-certificates sudo \
    docker.io docker-compose-v2 \
    poppler-utils chromium \
    x11-xserver-utils python3-tk x11-apps \
    ffmpeg libsm6 libxext6 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Node.js 20 (required for the Claude Code CLI)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Python virtual environment
RUN python3 -m venv /app/venv
ENV VIRTUAL_ENV=/app/venv
ENV PATH="/app/venv/bin:$PATH"

WORKDIR /app/new_dev_container
