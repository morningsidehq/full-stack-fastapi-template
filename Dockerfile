# Build frontend
FROM node:18-alpine as frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ .
RUN npm run build

# Build backend
FROM python:3.10-slim as backend-builder
WORKDIR /app/backend
COPY backend/pyproject.toml backend/uv.lock ./
COPY --from=ghcr.io/astral-sh/uv:0.5.11 /uv /uvx /bin/
ENV PATH="/app/backend/.venv/bin:$PATH"
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy
RUN uv sync --frozen --no-install-project
COPY backend/ .
RUN uv sync

# Final image
FROM python:3.10-slim
WORKDIR /app

# Install nginx
RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy built frontend
COPY --from=frontend-builder /app/frontend/dist /app/frontend

# Copy backend
COPY --from=backend-builder /app/backend /app/backend
COPY --from=backend-builder /app/backend/.venv /app/backend/.venv

# Copy environment file
COPY .env /app/.env

# Configure nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Copy start script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 80

CMD ["/app/start.sh"]