#!/bin/bash

# Start nginx
nginx

# Start backend
cd /app/backend
./.venv/bin/gunicorn app.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000 