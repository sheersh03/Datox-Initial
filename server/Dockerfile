FROM python:3.12-slim

WORKDIR /app
ENV PYTHONPATH=/app

RUN apt-get update && apt-get install -y gcc curl && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml /app/pyproject.toml
RUN pip install --no-cache-dir -U pip \
 && pip install --no-cache-dir "uv>=0.4" \
 && pip install --no-cache-dir .

# 👇 THIS MUST COPY alembic.ini
COPY . /app

EXPOSE 8080
