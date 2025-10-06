# boilerapi-app

Simple BoilerApi service exposing:
- `GET /api/v1/value`
- `GET /healthz`
- `GET /readyz`


## Run (local)
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8080
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
sudo python3 -m venv /opt/boilerapi-service/.venv
sudo /opt/boilerapi-service/.venv/bin/pip install --upgrade pip
```

# Install the BoilerApi service from GitHub or package repository
```bash
sudo /opt/boilerapi-service/.venv/bin/pip install https://github.com/ucef-h/boilerapi/releases/download/v1.0.5/boilerapi_app-1.0.5-py3-none-any.whl
```


## Copy the unit file to systemd’s directory
```bash
sudo cp /opt/boilerapi-service/deploy/systemd/boilerapi-app.service /etc/systemd/system/boilerapi-app.service
```

## Adjust permissions
```bash
sudo chmod 644 /etc/systemd/system/boilerapi-app.service
```

## Reload systemd to detect the new service
```bash
sudo systemctl daemon-reload
``` 

## Enable automatic startup at boot
```bash
sudo systemctl enable boilerapi-app
```

## Start the service immediately
```bash
sudo systemctl start boilerapi-app
```

## Verify status (should show active)
```bash
sudo systemctl status boilerapi-app --no-pager
```
