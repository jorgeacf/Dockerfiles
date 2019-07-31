#!/bin/bash

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x

if ! [ -e index.php -a -e bin/grav ]; then
  	echo "Required files not found in $PWD - Copying from ${SOURCE}..."
  	cp -r "$SOURCE"/. $PWD
	SKELETON_VERSION=1.4.2
	wget https://getgrav.org/download/skeletons/clean-blog-site/${SKELETON_VERSION}/grav-skeleton-clean-blog-v${SKELETON_VERSION}.zip -O /tmp/grav-skeleton.zip
	unzip /tmp/grav-skeleton.zip -d /tmp
	cp -r /tmp/grav-skeleton-*/. /var/www/html

  	echo "Modifing user..."
  	chown -R www-data:www-data $PWD
  	echo "Done."
fi



if [[ "$1" = 'grav' ]]; then
	
	bin/gpm selfupgrade -f -y
	bin/gpm update -f -y

	bin/gpm install admin -y
	bin/gpm install git-sync -y

	chown -R www-data:www-data /var/www/html
	rm -f /etc/nginx/sites-available/default
	rm -f /etc/nginx/sites-enabled/default

	/etc/init.d/nginx start
	/etc/init.d/php7.3-fpm start
	echo "Running..."
	tail -f tail -f /var/log/nginx/access.log
else
    exec "$@"
fi

exit 0;