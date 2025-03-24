# Use an official PHP image with Apache
FROM php:8.0-apache

# Install system dependencies and required packages, including build tools
RUN apt-get update && apt-get install -y \
    gnupg2 \
    curl \
    apt-transport-https \
    ca-certificates \
    libicu-dev \
    libonig-dev \
    libxml2-dev \
    unixodbc-dev \
    libssl-dev \
    build-essential \
    autoconf \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Add Microsoft repository for the ODBC drivers
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/$(grep -oP '(?<=VERSION_ID=")\d+' /etc/os-release)/prod.list \
      > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17

# Install dependencies for PHP extensions
RUN apt-get install -y \
    libmcrypt-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libicu-dev \
    libxml2-dev \
    unixodbc-dev

# Install and enable PHP extensions required by Mautic and SQL Server drivers
RUN docker-php-ext-install intl mbstring xml opcache

# Install and enable SQL Server drivers via PECL
RUN pecl install sqlsrv pdo_sqlsrv && docker-php-ext-enable sqlsrv pdo_sqlsrv

# Enable Apache mod_rewrite for proper URL handling in Mautic
RUN a2enmod rewrite

# Set the working directory to the Apache document root
WORKDIR /var/www/html

# Copy your Mautic source code into the container
COPY . /var/www/html

# Ensure the web server can write to the application files
RUN chown -R www-data:www-data /var/www/html

# Expose port 80 for Apache
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]
