# Basis-Image für PHP 8.0 mit FPM
FROM php:8.0-fpm

# Installiere Systempakete für ODBC
RUN apt-get update && apt-get install -y \
    unixodbc \
    unixodbc-dev \
    odbcinst \
    libpq-dev \
    gnupg2 \
    && apt-get clean

# Installiere den ODBC-Treiber für Microsoft SQL Server
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17

# Installiere PHP-Erweiterungen für PDO und ODBC
RUN docker-php-ext-install pdo_odbc pdo pdo_mysql

# Kopiere und konfiguriere die ODBC INI-Dateien
COPY odbcinst.ini /etc/odbcinst.ini
COPY odbc.ini /etc/odbc.ini

# Installiere NGINX
RUN apt-get install -y nginx

# Kopiere die NGINX-Konfiguration
COPY nginx.conf /etc/nginx/nginx.conf

# Starte PHP-FPM und NGINX
CMD service php-fpm start && nginx -g 'daemon off;'

# Exponiere Port 80
EXPOSE 80
