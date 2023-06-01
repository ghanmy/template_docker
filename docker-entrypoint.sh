#!/bin/sh


#adduser -D -g '' -G www-data www-data
#chown -R www-data:www-data /var/www/symfony
composer install
#php bin/console doctrine:schema:update --force
#php bin/console doctrine:fixtures:load

#chmod -R 777 /var/www/symfony/public/uploads/
chmod -R 777 /var/www/symfony/var/log/

yarn install
yarn encore dev

exec "$@"
