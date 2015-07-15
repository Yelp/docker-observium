#!/bin/bash

# == Fetch proper Observium version

community_http() {
    cd /tmp &&
    wget http://www.observium.org/observium-community-latest.tar.gz &&
    tar xvf observium-community-latest.tar.gz &&
    rm observium-community-latest.tar.gz
}

professional_svn() {
    cd /tmp &&
    svn co --non-interactive \
           --username $SVN_USER \
           --password $SVN_PASS \
           $SVN_REPO observium
}

if [[ "$USE_SVN" == "true" && "$SVN_USER" && "$SVN_PASS" && "$SVN_REPO" ]]
then
    professional_svn
else
    community_http
fi
# I know this seems ridiculous, but since /opt/observium/html is an external
# volume mount, svn throws a fit about it conflicting with the tree. Pulling
# SVN to temp directory and copying contents into /opt/observium was just the
# first way thought of to avoid dealing with the svn conflict resolution from
# script.
cp -r /tmp/observium/* /opt/observium/ && rm -rf /tmp/observium

# == Configuration section

# Queue jobs for later execution while configuration is being sorted out
atd

# Check for `config.php`. If it doesn't exist, use `config.php.default`,
# substituting SQL credentials with observium/"random".
if [ -f /config/config.php ]; then
  echo "Using existing PHP database config file."
  echo "/opt/observium/discovery.php -u" | at -M now + 1 minute
else
  echo "Loading PHP config from default."
  mkdir -p /config/databases
  cp /opt/observium/config.php.default /config/config.php
  chown nobody:users /config/config.php
  PW=$(date | sha256sum | cut -b -31)
  sed -i -e 's/PASSWORD/'$PW'/g' /config/config.php
  sed -i -e 's/USERNAME/observium/g' /config/config.php
fi

ln -s /config/config.php /opt/observium/config.php

# CHECK: Should we do this twice? It's done in Dockerfile and here. It's done
# here to recursively fix permissions of config.php and could be left here and
# taken out of Dockerfile unless anyone thinks it hurts the Dockerfile
# readability.
chown nobody:users -R /opt/observium
chmod 755 -R /opt/observium
