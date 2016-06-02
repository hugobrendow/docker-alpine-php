FROM alpine:latest

MAINTAINER Fábio Luciano <fabio@naoimporta.com>

ENV TIMEZONE            America/Sao_Paulo
ENV PHP_MEMORY_LIMIT    512M
ENV MAX_UPLOAD          50M
ENV PHP_MAX_FILE_UPLOAD 200
ENV PHP_MAX_POST        100M

RUN apk update && \
  apk upgrade && \
  apk add --update tzdata nginx supervisor && \
  cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
  echo "${TIMEZONE}" > /etc/timezone && \
  apk add --update php-mcrypt php-soap php-openssl php-gmp php-pdo_odbc \
    php-json php-dom php-pdo php-zip php-mysql php-sqlite3 php-apcu \
    php-pdo_pgsql php-bcmath php-gd php-xcache php-odbc php-pdo_mysql \
    php-pdo_sqlite php-gettext php-xmlreader php-xmlrpc php-bz2 php-memcache \
    php-mssql php-iconv php-pdo_dblib php-curl php-ctype php-fpm

RUN sed -i "s|;*daemonize\s*=\s*yes|daemonize = no|g" /etc/php/php-fpm.conf && \
  sed -i "s|;*listen\s*=\s*127.0.0.1:9000|listen = 9000|g" /etc/php/php-fpm.conf && \
  sed -i "s|;*listen\s*=\s*/||g" /etc/php/php-fpm.conf && \
  sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" /etc/php/php.ini && \
  sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php/php.ini && \
  sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|i" /etc/php/php.ini && \
  sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php/php.ini && \
  sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /etc/php/php.ini && \
  sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= 0|i" /etc/php/php.ini && \

  mkdir /www && \
  apk del tzdata && \
  rm -rf /var/cache/apk/*

RUN mkdir -p /tmp/nginx ; chown nginx /tmp/nginx

ADD files/supervisord.conf /etc/supervisord.conf
ADD files/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80 443

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
