FROM base

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
ARG APT_CACHE_ID
RUN --mount=type=cache,id=${APT_CACHE_ID},target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && apt-get --no-install-recommends install -y \
    apache2 \
    rrdtool \
    snmp \
    snmpd \
    php8.1 \
    php8.1-intl \
    php8.1-mysql \
    php8.1-snmp \
    php8.1-xml \
    php8.1-mbstring \
    php8.1-gd \
    php8.1-gmp \
    php8.1-zip \
    php8.1-ldap \
    php8.1-curl \
    cron

# Clone custom version of Cacti. Only PHP <= 5.4 are vulnerable to the CVE.
# Those versions are hard to find. Easier to run PHP 8 but slightly modify the
# code to introduce the same behavior that you'd find on PHP 5.4.
ADD --chown=www-data:www-data https://github.com/eihli/cacti.git#release/1.2.26-md5 /var/www/html/cacti

# Set up configuration
COPY --chown=www-data:www-data config.php /var/www/html/cacti/include/config.php
COPY php.ini /etc/php/8.1/apache2/php.ini
COPY cacti.conf /etc/apache2/sites-available/cacti.conf

# Set up cron job for poller
RUN echo "*/5 * * * * www-data php /var/www/html/cacti/poller.php > /dev/null 2>&1" > /etc/cron.d/cacti \
    && chmod 644 /etc/cron.d/cacti

# Configure Apache
COPY --chown=www-data:www-data .htaccess /var/www/html/cacti/.htaccess
COPY cacti.conf /etc/apache2/sites-available/
RUN a2dissite 000-default && \
    a2enmod rewrite && \
    a2ensite cacti && \
    phpenmod intl

# Create Apache foreground script
COPY apache2-foreground /usr/local/bin/apache2-foreground

COPY entrypoint.sh /app/entrypoint.sh
