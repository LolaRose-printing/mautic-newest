# Use an official PHP image with Apache
FROM php:8.0-apache

# Install system dependencies and build tools
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

# Install PHP extensions required by Mautic
RUN docker-php-ext-install intl mbstring xml opcache

# Update the PECL channel
RUN pecl channel-update pecl.php.net

# Install SQL Server drivers via PECL (explicit versions known to work with PHP 8.0)
RUN pecl install sqlsrv-5.11.1 pdo_sqlsrv-5.11.1 && docker-php-ext-enable sqlsrv pdo_sqlsrv

# Enable Apache mod_rewrite (required by Mautic)
RUN a2enmod rewrite

# Set working directory to the Apache document root
WORKDIR /var/www/html

# Copy your Mautic source code into the container
COPY . /var/www/html

# Ensure the web server has proper permissions on the application files
RUN chown -R www-data:www-data /var/www/html

# Expose port 80 for Apache
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]
