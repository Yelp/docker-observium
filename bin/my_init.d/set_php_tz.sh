#!/bin/bash
#
# == Title: set_php_tz.sh
# Set the timezone in PHP files, default to UTC

if [[ $CUSTOM_PHP_INI != 'true' ]] ; then
    if [ -f /etc/container_environment/TZ ] ; then
      sed -i \
          "s#\;date\.timezone\ \=#date\.timezone\ \=\ $TZ#g" \
          /etc/php5/cli/php.ini
      sed -i \
          "s#\;date\.timezone\ \=#date\.timezone\ \=\ $TZ#g" \
          /etc/php5/apache2/php.ini
    else
      echo "Timezone not specified by environment variable"
      echo UTC > /etc/container_environment/TZ
      sed -i \
          "s#\;date\.timezone\ \=#date\.timezone\ \=\ UTC#g" \
          /etc/php5/cli/php.ini
      sed -i \
          "s#\;date\.timezone\ \=#date\.timezone\ \=\ UTC#g" \
          /etc/php5/apache2/php.ini
    fi
fi
