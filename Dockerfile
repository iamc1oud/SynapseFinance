FROM python:3.13-slim

WORKDIR /app

# Install uv for fast dependency management
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install dependencies
RUN uv sync --frozen --no-dev

# Copy application code
COPY synapse/ ./synapse/

# Expose port
EXPOSE 8000

# Run the application
CMD ["uv", "run", "python", "synapse/manage.py", "runserver", "0.0.0.0:8000"]
