# NGINX README

This repository contains the configuration and `Dockerfile` for a custom Nginx image. This image serves as the reverse proxy and secure entry point for the entire application stack.

## Purpose

The `nginx` image extends the official Nginx Docker image with a few key modifications:

- It is pre-configured to act as a reverse proxy, routing public web traffic to the appropriate internal services on the Docker network.
- It is designed to work seamlessly with Certbot, managing and serving SSL certificates for secure HTTPS connections.

## How It Works

This image works in conjunction with the `rpi-docker-compose` repository. Certbot is a containerized version of the Certbot tool for managing SSL certificates with Cloudflare DNS, and the SSL certificates it generates are mounted as a volume into the Nginx container. This allows the Nginx container to use the certificates without needing to run Certbot itself, using inotify-tools to monitor the certificates for changes.

## Getting Started

To use this image, you will typically run it via `docker-compose` as part of the full application stack. The `rpi-docker-compose` repository handles the entire orchestration, including mounting the necessary volumes.

### As part of the main project

Refer to the `README.md` in the `rpi-docker-compose` repository for instructions on how to start the full application stack.

## Configuration

The Nginx configuration is modular and organized within `/etc/nginx/` inside the container:

- `nginx.conf`: The main entry point, loading server blocks based on the environment.
- `conf.d/`: Contains environment-specific server blocks:
  - `servers-public.conf`: Production config with SSL (ports 443).
  - `servers-dev.conf`: Local development config (port 80).
  - `servers-internal.conf`: Configuration for internal services not exposed publicly.
- `conf.d/includes/`: Reusable configuration snippets:
  - `upstream-vars.conf`: Defines variables for backend services.
  - `proxy-common.conf`: Shared proxy settings (timeouts, headers).
  - `bot-dropper.conf`: Logic to filter unwanted bot traffic.
