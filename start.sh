#!/bin/bash
set -e  # Exit on error

# Start nginx
nginx

# Start backend
cd /app/backend
if [ ! -f "./.venv/bin/gunicorn" ]; then
    echo "Error: gunicorn not found in virtual environment"
    exit 1
fi

source ./.venv/bin/activate
exec ./.venv/bin/gunicorn app.main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000 