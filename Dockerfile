# Verwende das Alpine-Image von tangramor/nginx-php8-fpm als Basis
FROM ghcr.io/tangramor/nginx-php8-fpm:alpine

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

# Installiere PHP-Erweiterungen für PDO und ODBC
RUN docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr \
    && docker-php-ext-install pdo_odbc pdo pdo_mysql

# Kopiere die ODBC INI-Dateien
COPY odbcinst.ini /etc/odbcinst.ini
COPY odbc.ini /etc/odbc.ini
COPY freetds.conf /etc/freetds/freetds.conf

# Exponiere notwendige Ports (HTTP, HTTPS, NetBIOS)
EXPOSE 80
EXPOSE 443
EXPOSE 2683
