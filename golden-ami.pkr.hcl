variable "aws_region" {
  type = string
}

variable "base_ami" {
  type = string
}

variable "version_tag" {
  type = string
}

variable "CODEARTIFACT_DOMAIN" {
  type = string
}

variable "CODEARTIFACT_OWNER" {
  type = string
}

variable "CODEARTIFACT_REGION" {
  type = string
}

variable "CODEARTIFACT_REPO" {
  type = string
}

variable "CODEARTIFACT_PACKAGE" {
  type = string
}

variable "CODEARTIFACT_TOKEN" {
  type = string
}

packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "golden_ami" {
  region          = var.aws_region
  instance_type   = "t3.micro"
  source_ami      = var.base_ami
  ssh_username    = "ec2-user"
  ami_name        = "golden-ami-${var.version_tag}"
  ami_description = "Golden AMI built from ${var.base_ami} with version ${var.version_tag}"

  tags = {
    Name    = "golden-ami-${var.version_tag}"
    Version = var.version_tag
  }
}

build {
  name    = "golden-ami-build"
  sources = ["source.amazon-ebs.golden_ami"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      # venv is built into Python3; install pip and tools
      "sudo yum install -y python3.13 python3.13-pip git",
      "sudo alternatives --install /usr/bin/python3 python3 /usr/bin/python3.13 2",
      "sudo useradd --system --no-create-home --shell /sbin/nologin boilerapi || true",
      "sudo mkdir -p /opt/boilerapi-service",
      "sudo chown -R boilerapi:boilerapi /opt/boilerapi-service",

      # Create venv and upgrade pip
      "sudo -u boilerapi python3 -m venv /opt/boilerapi-service/.venv",
      "sudo -u boilerapi /opt/boilerapi-service/.venv/bin/pip install --upgrade pip",

      # Debug printing CodeArtifact package
      "echo 'Installing package: ${var.CODEARTIFACT_PACKAGE}'",

      # Install from CodeArtifact (Basic Auth: user 'aws', password = token)
      "sudo -u boilerapi /opt/boilerapi-service/.venv/bin/pip install --index-url https://aws:${var.CODEARTIFACT_TOKEN}@${var.CODEARTIFACT_DOMAIN}-${var.CODEARTIFACT_OWNER}.d.codeartifact.${var.CODEARTIFACT_REGION}.amazonaws.com/pypi/${var.CODEARTIFACT_REPO}/simple/ ${var.CODEARTIFACT_PACKAGE}",

      # Run package-provided installer (assumes it installs systemd unit)
      "sudo /opt/boilerapi-service/.venv/bin/boilerapi-install-systemd"
    ]
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}