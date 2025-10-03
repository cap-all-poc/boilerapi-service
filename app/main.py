from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class ValueResponse(BaseModel):
    value: str | int

class HealthResponse(BaseModel):
    status: str

@app.get("/api/v1/value", response_model=ValueResponse)
def get_value():
    # Example value, replace with your logic if needed
    return ValueResponse(value="42")

@app.get("/healthz", response_model=HealthResponse)
def healthz():
    return HealthResponse(status="ok")

@app.get("/readyz", response_model=HealthResponse)
def readyz():
    # Add readiness logic if needed
    return HealthResponse(status="ok")
