# Use the official Nginx base image. The "alpine" variant is very small,
# which is great for a lean production image.
FROM nginx:1.29.1-alpine

# Add the 'www-data' user to the existing 'www-data' group.
# This fixes the "getpwnam("www-data") failed" error and the "group 'www-data' in use"
# error by creating the user and assigning it to the pre-existing group.
RUN adduser -S www-data -G www-data

# Create the /var/cache/nginx directories with correct permissions
# This prevents the "Permission denied" error when Nginx tries to write cache files
RUN mkdir -p /var/cache/nginx/client_temp \
    && chown -R www-data:www-data /var/cache/nginx

# Create a dedicated directory for Nginx's PID file and give it the correct permissions.
# This fixes the "Permission denied" error for /var/run/nginx.pid.
RUN mkdir -p /var/run/nginx \
    && chown -R www-data:www-data /var/run/nginx

# Remove the default Nginx configuration file. This is an important step
# to ensure our custom configuration is the only one used.
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom main nginx.conf file into the container.
# This file will act as the entry point for all other configurations.
COPY ./nginx.conf /etc/nginx/nginx.conf

# Create the sites-available and sites-enabled directories inside the container.
RUN mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled

# Copy our site-specific configuration file into the sites-available directory.
COPY ./sites-available/default.conf /etc/nginx/sites-available/default.conf

# Create a symbolic link to enable the default site. This mimics
# the standard Nginx directory structure and makes it modular.
RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

# Set the user to 'www-data' so Nginx runs with the correct permissions.
USER www-data

# Expose port 80 and 443. This is more of a documentation step for the image
# itself, but it's a good practice to include. The actual port mapping is
# handled by the `docker-compose.yml` file.
EXPOSE 80
EXPOSE 443

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
