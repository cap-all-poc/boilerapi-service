# Use a lightweight Python image as base.
FROM python:3.11-slim

# Avoid buffering Python output (makes logs show up straight away) and disable writing .pyc files.
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Create a working directory for the application source code.
WORKDIR /app

# Copy dependency lists before the rest of the code.  Doing this first allows Docker to
# cache the layer containing installed dependencies, so subsequent rebuilds are faster
# when only application code changes.
COPY requirements.txt requirements-prod.txt ./

# Upgrade pip and install pinned production dependencies.  requirements-prod.txt
# pulls in gunicorn and the base dependencies from requirements.txt.
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements-prod.txt

# Copy the application code into the container image.  This includes the BoilerAPI
# application code and supporting files.
COPY app ./app

# Expose the port that the BoilerAPI application will listen on.  The systemd unit
# binds to port 8080, so we do the same here.
EXPOSE 8080

# Use Gunicorn with Uvicorn workers to run the BoilerAPI application.  The number
# of workers can be adjusted via the `-w` option; two workers is a sane default
# for small deployments.  The binding address `0.0.0.0:8080` makes the service
# available to other containers or the host.
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "-w", "2", "-b", "0.0.0.0:8080", "app.main:app"]