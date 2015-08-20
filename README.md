Observium
=========

Dockerized version of Observium with support for external database, both
communitiy and professional editions (via arbritrary svn source), packages
to allow native LDAP auth, and easy plugin support by exposing htmldir as a
volume.

At Yelp we use this to provide portability to our NMS. With a flexible
image, it's easy to manage 2+ instances with Puppet or 
[insert way to configure/schedule containers here]. Good use cases would be 
instances for corp and prod, managed services and internal, or just a single 
one that's more predictable on any box.

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

| Volume                        | Purpose                                                                                                                       |
|:------------------------------|:------------------------------------------------------------------------------------------------------------------------------|
| `/config`                     | `config.php` should go here                                                                                                   |
| `/opt/observium/html`         | This allows you to add HTML plugins if you wish (such as weathermap!)                                                         |
| `/opt/observium/logs`         | HTTP error/access, `observium.log` and `update-errors.log`                                                                    |
| `/opt/observium/rrd`          | Mount this where you have a ample space and back up!                                                                          |
| `/var/run/mysqld/mysqld.sock` | If you're running MySQL on the local Docker host, make use of this volume and set the SQL host to `localhost` in `config.php` |

If you need to sub-in random, single files just add an extra `-v` argument to
your run (or however you're starting the container. Puppet anyone?) to the
path. We do this for `/etc/php5/apache2/php.ini`

Ports
-----

Only TCP/8000 is exposed.

Environment variables
---------------------

| Variable            | Default Value    |
|:--------------------|:-----------------|
| `WORKERS`           | 2                |
| `USE_WEATHERMAP`    | false            |
| `CUSTOM_PHP_INI`    | false            |
| `USE_SVN`           | false            |
| `SVN_USER`          | N/A              |
| `SVN_PASS`          | N/A              |
| `SVN_REPO`          | N/A              |


If you don't have a subscription but run your own managed copy, feel free to
sub-in your own repo.

Depending on your number of devices, the default 2 workers likely isn't enough
based on a polling period every 5 minutes. Just pass ``WORKERS=32``, for
example, if your total core count is 32 and you want to use them all.

Weathermap
----------

As in the list above, setting `USE_WEATHERMAP` will install network-weathermap
under the htmldir if not there already and schedule map-poller.php in cron.

To modify configuration, volume mount observium's htmldir to access weathermap.

Maintenance
-----------

Observium has a tendancy to become huge over time with its eventlog containing
every port that flaps, syslog, performance timings for every run, and more.

This image comes with a cronjob that will run daily for you to clean this up.
By default it will run with the switches set for eventlog and performance
timings, but like most things in this image it can be overridden by providing
`HOUSEKEEPING_ARGS` as an environment variable.

Please checkout out the [initial post] in the mailing list for details on how
to configure your config.php for better control and what each switch does.

[initial post]: http://postman.memetic.org/pipermail/observium/2014-July/007264.html

Notes
-----

This image installs and runs rrdcached. To make use of it, make sure your
observium configuration sets

    $config['rrdcached']    = "unix:/var/run/rrdcached.sock"
