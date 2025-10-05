# fastapi-app

Simple FastAPI service exposing:
- `GET /api/v1/value`
- `GET /healthz`
- `GET /readyz`


## Run (local)
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8080
```

# Install systemd

## Create a dedicated system account for the FastAPI service
```bash
sudo useradd --system --no-create-home --shell /usr/sbin/nologin fastapi
```

## Create the application directory and assign ownership
```bash
sudo mkdir -p /opt/fastapi-service
sudo chown -R fastapi:fastapi /opt/fastapi-service
```

## Install Python and Prerequisites
```bash
sudo yum update -y
sudo yum install -y python3 python3-venv git
```

## Create virtual environment under the application directory
```bash
sudo python3 -m venv /opt/fastapi-service/.venv
sudo /opt/fastapi-service/.venv/bin/pip install --upgrade pip
```

# Install the FastAPI service from GitHub or package repository
```bash
sudo /opt/fastapi-service/.venv/bin/pip install https://github.com/ucef-h/fastapi/releases/download/v1.0.5/fastapi_app-1.0.5-py3-none-any.whl
``` 


## Copy the unit file to systemd’s directory
```bash
sudo cp /opt/fastapi-service/deploy/systemd/fastapi-app.service /etc/systemd/system/fastapi-app.service
``` 

## Adjust permissions
```bash
sudo chmod 644 /etc/systemd/system/fastapi-app.service
``` 

## Reload systemd to detect the new service
```bash
sudo systemctl daemon-reload
``` 

## Enable automatic startup at boot
```bash
sudo systemctl enable fastapi-app
``` 

## Start the service immediately
```bash
sudo systemctl start fastapi-app
``` 

## Verify status (should show active)
```bash
sudo systemctl status fastapi-app --no-pager
``` 
