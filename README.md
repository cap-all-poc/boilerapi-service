# boilerapi-service

Simple BoilerApi service exposing:
- `GET /api/v1/value`
- `GET /healthz`
- `GET /readyz`


## Run (local)
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8080
```

# Install Docker 

## To pull a specific version (recommended for stable deployments):
```bash
docker pull ghcr.io/cap-all-poc/boilerapi-service:v1.0.1
```

## Run the Container on particular version:
```bash
docker run -d -p 8080:8080 ghcr.io/cap-all-poc/boilerapi-service:v1.0.1
```

## The  service will now be accessible at:
```bash
curl http://localhost:8080
```

# Install systemd

## Create a dedicated system account for the BoilerApi service
```bash
sudo useradd --system --no-create-home --shell /usr/sbin/nologin boilerapi
```

## Create the application directory and assign ownership
```bash
sudo mkdir -p /opt/boilerapi-service
sudo chown -R boilerapi:boilerapi /opt/boilerapi-service
```

## Install Python and Prerequisites
```bash
sudo yum update -y
sudo yum install -y python3 python3-venv git
```

## Create virtual environment under the application directory
```bash
sudo -u boilerapi python3 -m venv /opt/boilerapi-service/.venv
sudo -u boilerapi /opt/boilerapi-service/.venv/bin/pip install --upgrade pip
```

# Install the BoilerApi service from GitHub or package repository
```bash
sudo -u boilerapi /opt/boilerapi-service/.venv/bin/pip install https://github.com/cap-all-poc/boilerapi-service/releases/download/v1.0.6/boilerapi_service-1.0.6-py3-none-any.whl
```


## Install and enable the systemd service
```bash
sudo /opt/boilerapi-service/.venv/bin/boilerapi-install-systemd
```

## Verify status (should show active)
```bash
sudo systemctl status boilerapi-service --no-pager
```

## Restart or stop when needed
```bash
sudo systemctl restart boilerapi-service
sudo systemctl stop boilerapi-service
```
