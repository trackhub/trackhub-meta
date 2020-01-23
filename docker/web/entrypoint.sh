#!/bin/bash

set -e

usermod -u ${WEB_UID} www-data

until nc -z sql 3306
do
    echo "Waiting for MariaDB..."
    sleep 1
done

echo "Initialize website"
pushd /var/www/website
composer install
yarn install
yarn encore dev
popd

echo "Initialize graphql"
pushd /var/www/graphql
composer install
popd

echo "Migrating the database..."
pushd /var/www/graphql/script/migration
composer install --no-dev && ./vendor/bin/phinx migrate
popd

echo "Starting the Apache server..."
apachectl -D FOREGROUND
