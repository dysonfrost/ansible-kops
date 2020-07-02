#!/bin/bash

# terminate on errors
set -e

# Environment variables
SOURCE_FOLDER=${SOURCE_FOLDER:-/usr/src/wordpress}
THEME_FOLDER=${THEME_FOLDER:-/themes}
PLUGIN_FOLDER=${PLUGIN_FOLDER:-/plugins}
PROJECT_ROOT=${PROJECT_ROOT:-/var/www/wp-content}
WORDPRESS_SITE_URL=${WORDPRESS_SITE_URL:-"localhost"}
WORDPRESS_SITE_USER=${WORDPRESS_SITE_USER:-"admin"}
WORDPRESS_SITE_PASSWORD=${WORDPRESS_SITE_PASSWORD:-"password"}
WORDPRESS_SITE_EMAIL=${WORDPRESS_SITE_EMAIL:-"admin@example.com"}
WORDPRESS_SITE_TITLE=${WORDPRESS_SITE_TITLE:-"Welcome!"}
WORDPRESS_ACTIVATE_THEME=${WORDPRESS_ACTIVATE_THEME:-"creativeily"}


# Check if volume is empty
if [ ! "$(ls -A "/var/www/wp-content" 2>/dev/null)" ]; then
    echo 'Setting up wp-content volume'
    # Copy wp-content from Wordpress src to volume
    cp -r ${SOURCE_FOLDER}/wp-content /var/www/
    chown -R nobody.nobody /var/www

    # Generate secrets
    curl -f https://api.wordpress.org/secret-key/1.1/salt/ >> ${SOURCE_FOLDER}/wp-secrets.php

    # Add themes
    for themeDir in `find ${THEME_FOLDER} -type d -maxdepth 1 -mindepth 1`
    do
        cp -r "$themeDir" ${PROJECT_ROOT}/themes
    done

    # Add plugins
    for pluginDir in `find ${PLUGIN_FOLDER} -type d -maxdepth 1 -mindepth 1`
    do
        cp -r "$pluginDir" ${PROJECT_ROOT}/plugins
    done
fi

# TODO
# Find a way to make sure MySQL container is ready
sleep 10

# Setting up wordpress activation
wp core install --path=${SOURCE_FOLDER} \
    --url=${WORDPRESS_SITE_URL} \
    --title=${WORDPRESS_SITE_TITLE} \
    --admin_user=${WORDPRESS_SITE_USER} \
    --admin_password=${WORDPRESS_SITE_PASSWORD} \
    --admin_email=${WORDPRESS_SITE_EMAIL} \
    --skip-email

# Install and Activate theme.
wp theme install ${WORDPRESS_ACTIVATE_THEME} --path=${SOURCE_FOLDER} --activate

# Activate plugins.
for pluginDir in `find ${PLUGIN_FOLDER} -type d -maxdepth 1 -mindepth 1`
do
    pluginName=$(basename ${pluginDir})
    wp plugin install $pluginName --path=${SOURCE_FOLDER} --activate
done

exec "$@"
