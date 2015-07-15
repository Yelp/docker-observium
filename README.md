Observium
=========

Dockerized version of Observium with support for external database, both
communitiy and professional editions (via arbritrary svn source), packages
to allow native LDAP auth, and easy plugin support by exposing htmldir as a
volume.

Using this image
----------------

Examples assume the following directory layout:

    $ tree $PWD
    /opt/observium/volumes
    ├── config
    │   └── config.php
    ├── html
    ├── logs
    └── rrd

Linking volumes and using Observium CE:

    $ docker run -d \
        --name observium \
        -p 8000:8000 \
        -v /opt/observium/volumes/config:/config \
        -v /opt/observium/volumes/html:/opt/observium/html \
        -v /opt/observium/volumes/logs:/opt/observium/logs \
        -v /opt/observium/volumes/rrd:/opt/observium/rrd \
        yelp/observium

Using Observium PE (or another SVN source):

    $ docker run -d \
        --name observium \
        -p 8000:8000 \
        -v /opt/observium/volumes/config:/config \
        -v /opt/observium/volumes/html:/opt/observium/html \
        -v /opt/observium/volumes/logs:/opt/observium/logs \
        -v /opt/observium/volumes/rrd:/opt/observium/rrd \
        -e USE_SVN=true \
        -e SVN_USER=user@example.com \
        -e SVN_PASS=dfed555743854a475345ae01a7668acc \
        -e SVN_REPO=http://svn.observium.org/svn/observium/trunk \
        yelp/observium

Volumes
-------

The following volumes are set in the container:

1. `/config`

   `config.php` should go here

2. `/opt/observium/html`

   This allows you to add HTML plugins if you wish (such as weathermap!)

3. `/opt/observium/logs`

   HTML error and access logs will be placed here as well as
   `observium.log` and `update-errors.log`

4. `/opt/observium/rrd`

   Preferably mount this volume where you have a good amount of space.
   Recommended that you back these up.

5. `/var/run/mysqld/mysqld.sock`

   If you're running MySQL on the local docker host, make use of this volume
   and set the SQL host to `localhost` is `config.php`

If you need to sub-in random, single files just add an extra `-v` argument to
your run (or however you're starting the container. Puppet anyone?) to the
path. We do this for `/etc/php5/apache2/php.ini`

Ports
-----

Only TCP/8000 is exposed.

Environment variables
---------------------

All of the environment variables that are used were shown above.

    USE_SVN=true
    SVN_USER=username
    SVN_PASS=password
    SVN_REPO=http://url/to/repo@revision

If you don't have a subscription but run your own managed copy, feel free to
sub-in your own repo.
