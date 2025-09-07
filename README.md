# RPI-NGINX README

This repository contains the configuration and `Dockerfile` for a custom Nginx image optimized for a Raspberry Pi. This image serves as the reverse proxy and secure entry point for the entire application stack.

## Purpose

The `rpi-nginx` image extends the official Nginx Docker image with a few key modifications:

- It is built for the ARM architecture to run efficiently on a Raspberry Pi.
- It is pre-configured to act as a reverse proxy, routing public web traffic to the appropriate internal services on the Docker network.
- It is designed to work seamlessly with Certbot, managing and serving SSL certificates for secure HTTPS connections.

## How It Works

This image works in conjunction with the `rpi-docker-compose` repository. Certbot is installed on the host machine (your Raspberry Pi), and the SSL certificates it generates are mounted as a volume into the Nginx container. This allows the Nginx container to use the certificates without needing to run Certbot itself.

## Getting Started

To use this image, you will typically run it via `docker-compose` as part of the full application stack. The `rpi-docker-compose` repository handles the entire orchestration, including mounting the necessary volumes.

### As part of the main project

Refer to the `README.md` in the `rpi-docker-compose` repository for instructions on how to start the full application stack.

### To build the image manually

If you need to build the image separately (e.g., for testing or CI/CD), you can use the following commands from this repository's root directory:

```bash
docker build -t emb417/rpi-nginx:latest .
docker push emb417/rpi-nginx:latest
```

## Configuration

Nginx configurations are managed in the `sites-available` directory and symlinked to `sites-enabled`.

- **`sites-available/default.conf`**: This is the configuration for your production environment, including SSL settings and the correct `proxy_pass` directives for your public domains.
- **`sites-available/default-local.conf`**: This is a simplified configuration for local development. It uses plain HTTP and a `localhost` server name.
- **`nginx.conf`**: The main Nginx configuration file.

To update the Nginx configuration, modify the files in `sites-available` and then rebuild and push the Docker image to your container registry.
