#!/bin/bash

set -e

usermod -u ${WEB_UID} www-data

until nc -z sql 3306
do
    echo "Waiting for MariaDB..."
    sleep 1
done

echo "Migrating the database..."
pushd /var/www/script/migration
composer install --no-dev && ./vendor/bin/phinx migrate
popd

echo "Starting the Apache server..."
apachectl -D FOREGROUND
