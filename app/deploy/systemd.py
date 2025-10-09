# app/deploy/systemd.py
import os, sys, subprocess
from importlib.resources import files

UNIT = "boilerapi-service.service"
TARGET = f"/etc/systemd/system/{UNIT}"

def is_root_unix() -> bool:
    return os.name != "nt" and hasattr(os, "geteuid") and os.geteuid() == 0  # type: ignore[attr-defined]

def main():
    if os.name == "nt":
        print("Windows detected: systemd not available. No changes applied.")
        return

    #if not is_root_unix():
    #    print("Please run this command with sudo (root privileges).")
    #    sys.exit(1)

    # read template from installed package data
    src = (files("app.deploy.systemd") / UNIT).read_text()

    # point ExecStart to the venv’s gunicorn next to this python
    gunicorn_bin = os.path.join(os.path.dirname(sys.executable), "gunicorn")
    src = src.replace("/opt/boilerapi-service/.venv/bin/gunicorn", gunicorn_bin)

    with open(TARGET, "w") as f:
        f.write(src)
    os.chmod(TARGET, 0o644)

    subprocess.run(["systemctl", "daemon-reload"], check=True)
    subprocess.run(["systemctl", "enable", "--now", "boilerapi-service"], check=True)
    print(f"Installed and started: {TARGET}")

if __name__ == "__main__":
    main()
