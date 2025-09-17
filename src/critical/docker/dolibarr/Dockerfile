FROM base

ENV DOLI_VERSION=9.0.1

ARG WWW_USER_ID=33
ARG WWW_GROUP_ID=33

ADD https://github.com/Dolibarr/dolibarr/archive/${DOLI_VERSION}.tar.gz /tmp/dolibarr.tar.gz
RUN tar -xzvf /tmp/dolibarr.tar.gz -C /tmp && \
 cp -r /tmp/dolibarr-${DOLI_VERSION}/htdocs/* /var/www/html/ && ln -s /var/www/html /var/www/htdocs && \
 cp -r /tmp/dolibarr-${DOLI_VERSION}/scripts /var/www/ && \
 rm -rf /tmp/dolibarr

RUN usermod -u $WWW_USER_ID www-data && groupmod -g $WWW_USER_ID www-data && \
    mkdir -p /var/www/documents && \
    chown -R www-data:www-data /var/www

RUN sed -i 's/Listen 80/Listen 9090/' /etc/apache2/ports.conf && \
    sed -i 's/<VirtualHost \*:80>/<VirtualHost *:9090>/' /etc/apache2/sites-enabled/000-default.conf

WORKDIR /app

COPY pre-start.sh /init/pre-start.sh
