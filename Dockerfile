# Basis-Image für PHP 8.0 mit FPM
FROM php:8.0-fpm

# Installiere Systempakete für ODBC und PHP
RUN apt-get update && apt-get install -y \
    unixodbc \
    unixodbc-dev \
    odbcinst \
    libpq-dev \
    curl \
    gnupg2 \
    apt-transport-https \
    build-essential \
    nginx \
    && apt-get clean

# Füge das neueste Microsoft SQL Server ODBC-Repository hinzu
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17

# Installiere PHP-Erweiterungen
RUN docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr \
    && docker-php-ext-install pdo_odbc pdo pdo_mysql

# Kopiere die ODBC INI-Dateien
COPY odbcinst.ini /etc/odbcinst.ini
COPY odbc.ini /etc/odbc.ini

# Installiere NGINX und kopiere Konfigurationsdatei
COPY nginx.conf /etc/nginx/nginx.conf

# Starte PHP-FPM und NGINX
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]

# Exponiere Port 80
EXPOSE 80
