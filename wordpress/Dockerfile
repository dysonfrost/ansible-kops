FROM alpine:3.10
LABEL Maintainer="Jeremy Reisser <jeremy.reisser@gmail.com>"

# WordPress
ENV WORDPRESS_VERSION 5.4
ENV WORDPRESS_SHA1 d5f1e6d7cadd72c11d086a2e1ede0a72f23d993e
ENV PROJECT_ROOT /var/www/wp-content
ENV SOURCE_FOLDER /usr/src/wordpress
ENV THEME_FOLDER /themes
ENV PLUGIN_FOLDER /plugins

# Install packages
RUN apk --no-cache add \
  php7 \
  php7-fpm \
  php7-mysqli \
  php7-json \
  php7-openssl \
  php7-curl \
  php7-zlib \
  php7-xml \
  php7-phar \
  php7-intl \
  php7-dom \
  php7-xmlreader \
  php7-xmlwriter \
  php7-exif \
  php7-fileinfo \
  php7-sodium \
  php7-openssl \
  php7-gd \
  php7-imagick \
  php7-simplexml \
  php7-ctype \
  php7-mbstring \
  php7-zip \
  php7-opcache \
  nginx \
  supervisor \
  curl \
  bash \
  less

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/zzz_custom.conf
COPY config/php.ini /etc/php7/conf.d/zzz_custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# wp-content volume
VOLUME /var/www/wp-content
WORKDIR /var/www/wp-content
RUN chown -R nobody.nobody /var/www

RUN mkdir -p /usr/src ${THEME_FOLDER} ${PLUGIN_FOLDER}

# Upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
RUN curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz \
	&& echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
	&& tar -xzf wordpress.tar.gz -C /usr/src/ \
	&& rm wordpress.tar.gz \    
	&& chown -R nobody.nobody ${SOURCE_FOLDER}

# Remove all default plugins that are shipped with Wordpress. Also some other non-core files.
# Maintain the default index.php for security reason
RUN find ${SOURCE_FOLDER}/wp-content/themes/ -maxdepth 1  -mindepth 1 -type d -exec rm -r {} \;; \
    find ${SOURCE_FOLDER}/wp-content/plugins/ -maxdepth 1  -mindepth 1 -type d -exec rm -r {} \;; \
    rm ${SOURCE_FOLDER}/wp-config-sample.php; \
    rm ${SOURCE_FOLDER}/wp-content/plugins/hello.php; \
    rm ${SOURCE_FOLDER}/readme.html

# Add WP CLI
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# WP Themes
COPY themes ${THEME_FOLDER}
RUN chown -R nobody.nobody ${THEME_FOLDER} && chmod 640 ${THEME_FOLDER}

# WP Plugins
COPY plugins ${PLUGIN_FOLDER}
RUN chown -R nobody.nobody ${PLUGIN_FOLDER} && chmod 640 ${PLUGIN_FOLDER}

# WP config
COPY wp-config.php ${SOURCE_FOLDER}
RUN chown nobody.nobody ${SOURCE_FOLDER}/wp-config.php && chmod 640 ${SOURCE_FOLDER}/wp-config.php

# Append WP secrets
COPY wp-secrets.php ${SOURCE_FOLDER}
RUN chown nobody.nobody ${SOURCE_FOLDER}/wp-secrets.php && chmod 640 ${SOURCE_FOLDER}/wp-secrets.php

# Entrypoint to copy wp-content
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1/wp-login.php