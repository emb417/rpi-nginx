# Use the official Nginx base image. The "alpine" variant is very small.
FROM nginx:stable-alpine

ENV TZ="America/Los_Angeles"

# Install the 'inotify-tools' package to monitor changes in the /etc/letsencrypt/live directory
# This is required to reload the Nginx configuration when the certificate files change
RUN apk add --no-cache inotify-tools

# Add the 'www-data' user to the existing 'www-data' group.
RUN adduser -S www-data -G www-data

# Create the /var/cache/nginx directories with correct permissions
RUN mkdir -p /var/cache/nginx/client_temp \
    && chown -R www-data:www-data /var/cache/nginx

# Create a dedicated directory for Nginx's PID file and give it the correct permissions.
RUN mkdir -p /var/run/nginx \
    && chown -R www-data:www-data /var/run/nginx

# Remove the default Nginx configuration file. This is an important step
# to ensure our custom configuration is the only one used.
RUN rm /etc/nginx/conf.d/default.conf

# Remove the default Nginx log files.
RUN rm -f /var/log/nginx/access.log /var/log/nginx/error.log

# Create a dedicated directory for Nginx's log files and give it the correct permissions.
RUN mkdir -p /var/log/nginx \
    && chown -R www-data:www-data /var/log/nginx

# Copy our custom main nginx.conf file into the container.
# This file will act as the entry point for all other configurations.
COPY ./nginx.conf /etc/nginx/nginx.conf

# Create the includes directory inside the container.
RUN mkdir -p /etc/nginx/conf.d/includes

# Copy our custom configuration files into the container.
COPY ./conf.d/includes/* /etc/nginx/conf.d/includes/.
COPY ./conf.d/security/* /etc/nginx/conf.d/security/.
COPY ./conf.d/*.conf /etc/nginx/conf.d/.

# Download the list of Cloudflare IPs and create a configuration file to set the real IP from Cloudflare.
RUN curl -s https://www.cloudflare.com/ips-v4 | sed 's/^/set_real_ip_from /;s/$/;/' > /etc/nginx/conf.d/security/cloudflare-realip.conf \
    && echo "" >> /etc/nginx/conf.d/security/cloudflare-realip.conf \
    && curl -s https://www.cloudflare.com/ips-v6 | sed 's/^/set_real_ip_from /;s/$/;/' >> /etc/nginx/conf.d/security/cloudflare-realip.conf \
    && echo "" >> /etc/nginx/conf.d/security/cloudflare-realip.conf \
    && echo "real_ip_header CF-Connecting-IP;" >> /etc/nginx/conf.d/security/cloudflare-realip.conf

# Set the user to 'www-data' so Nginx runs with the correct permissions.
USER www-data

# Expose port 80 and 443.
EXPOSE 80
EXPOSE 443

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
