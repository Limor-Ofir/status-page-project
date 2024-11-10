# Dockerfile.nginx
FROM nginx:latest

# Create application directory
RUN mkdir -p /opt/status-page/statuspage/static
# Copy the static files for css styling
COPY ./static/ /opt/status-page/statuspage/static/

# Copy your custom NGINX config to the container

COPY  nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Add SSL certificates
COPY  ./certs/status-page.crt /etc/ssl/certs/
COPY  ./certs/status-page.key /etc/ssl/private/
RUN chmod 600 /etc/ssl/private/status-page.key


# Expose ports 80 and 443 for HTTP and HTTPS traffic
EXPOSE 80 443

# Start Nginx in the foreground to keep the container running
CMD ["nginx", "-g", "daemon off;"]
