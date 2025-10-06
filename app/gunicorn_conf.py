
import multiprocessing as mp
import os

# --- Bind / networking ---
bind = f"0.0.0.0:{os.getenv('PORT', '8080')}"
backlog = 2048  # reasonable queue size for bursts

# --- Worker model ---
# Default to UvicornWorker (ASGI: FastAPI/Starlette). Override if you run WSGI.
worker_class = os.getenv("GUNICORN_WORKER_CLASS", "uvicorn.workers.UvicornWorker")

# Default workers: 2–4 per CPU core. Start with 2 * cores; override via env if needed.
_cpu = max(mp.cpu_count(), 1)
workers = int(os.getenv("GUNICORN_WORKERS", str(max(2, min(32, _cpu * 2)))))

# Threads are mainly for sync workers; harmless for Uvicorn but not required.
threads = int(os.getenv("GUNICORN_THREADS", "1"))

# Preload app for copy-on-write memory savings and faster forks.
preload_app = True

# --- Timeouts / keepalive ---
# Request hard timeout (seconds). 60–120 is typical in prod; default 60.
timeout = int(os.getenv("GUNICORN_TIMEOUT", "60"))

# Time allowed for graceful worker shutdown/reload before SIGKILL.
graceful_timeout = int(os.getenv("GUNICORN_GRACEFUL_TIMEOUT", "30"))

# TCP keep-alive between requests on persistent connections.
keepalive = int(os.getenv("GUNICORN_KEEPALIVE", "5"))

# --- Reliability knobs ---
# Restart workers after N requests to mitigate leaks (leave 0 to disable).
max_requests = int(os.getenv("GUNICORN_MAX_REQUESTS", "0"))
max_requests_jitter = int(os.getenv("GUNICORN_MAX_REQUESTS_JITTER", "0"))

# --- Logging (stdout/stderr for K8s & systemd journal) ---
accesslog = "-"     # stdout
errorlog = "-"      # stderr
loglevel = os.getenv("GUNICORN_LOGLEVEL", "info")
capture_output = True
