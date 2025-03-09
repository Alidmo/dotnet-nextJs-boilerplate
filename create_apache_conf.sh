#!/bin/bash
set -e

# Expects two parameters: PROJECT_DIR and projectName
PROJECT_DIR="$1"
projectName="$2"

cat <<EOF > "${PROJECT_DIR}/apache/httpd.conf"
ServerName my.${projectName}.local
Listen 80

# Load necessary modules
LoadModule mpm_event_module modules/mod_mpm_event.so
LoadModule unixd_module modules/mod_unixd.so
LoadModule log_config_module modules/mod_log_config.so
LoadModule dir_module modules/mod_dir.so
LoadModule authz_core_module modules/mod_authz_core.so
LoadModule authz_host_module modules/mod_authz_host.so
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so

User daemon
Group daemon

ErrorLog "/proc/self/fd/2"
CustomLog "/proc/self/fd/1" common

DirectoryIndex index.html

DocumentRoot "/usr/local/apache2/htdocs"

<Directory "/usr/local/apache2/htdocs">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>

ProxyPreserveHost On
ProxyRequests Off
<Proxy "*">
    Require all granted
</Proxy>

ProxyPass "/" "http://frontend:3000/" retry=0
ProxyPassReverse "/" "http://frontend:3000/"

ProxyPass "/api/" "http://backend:5000/api/" retry=0
ProxyPassReverse "/api/" "http://backend:5000/api/"
EOF

echo "Custom Apache configuration file created at ${PROJECT_DIR}/apache/httpd.conf."
