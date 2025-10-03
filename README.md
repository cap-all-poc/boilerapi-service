# fastapi-app

Simple FastAPI service exposing:
- `GET /api/v1/value`
- `GET /healthz`
- `GET /readyz`

## Run (local)
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8080
