# == Observium
#
# Provide the following environment variables to source Observium from your
# Professional Edition subscription instead of the Community Edition upstream:
#
#   USE_SVN=true
#   SVN_USER=username
#   SVN_PASS=password
#   SVN_REPO=http://url/to/repo@rev
#
# If you don't have a subscription but run your own managed repository, 
# SVN_REPO is arbritrarily accepted. If USE_SVN is specified, credentials and
# repository information must also be otherwise will fallback to community
# version.
#
# The following volumes may be used with their descriptions next to them:
#
#   /config                     : Should contain your `config.php`, otherwise
#                                 default will be used
#   /opt/observium/html         : Provided to ease adding plugis (weathermap!)
#   /opt/observium/logs         : Would be nice to store these somewhere 
#                                 non-volatile!
#   /opt/observium/rrd          : Will consume the most storage.
#   /var/run/mysqld/mysqld.sock : If your MySQL server is on the same host that
#                                 serves the container, setting 'localhost' in 
#                                 observium config will look for the unix 
#                                 socket instead of using TCP.
#
#
FROM phusion/baseimage:0.9.16
MAINTAINER Codey Oxley <codey@yelp.com>
EXPOSE 8000/tcp
VOLUME ["/config", \
        "/opt/observium/html", \
        "/opt/observium/logs", \
        "/opt/observium/rrd", \
        "/var/run/mysqld/mysqld.sock"]

# === phusion/baseimage pre-work
CMD ["/sbin/my_init"]

# === General System

# Avoid any interactive prompting
ENV DEBIAN_FRONTEND noninteractive

# Language specifics
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Install locales
RUN locale-gen cs_CZ.UTF-8
RUN locale-gen de_DE.UTF-8
RUN locale-gen en_US.UTF-8
RUN locale-gen es_ES.UTF-8
RUN locale-gen fr_FR.UTF-8
RUN locale-gen it_IT.UTF-8
RUN locale-gen pl_PL.UTF-8
RUN locale-gen pt_BR.UTF-8
RUN locale-gen ru_RU.UTF-8
RUN locale-gen sl_SI.UTF-8
RUN locale-gen uk_UA.UTF-8

# Install Observium prereqs
RUN apt-get update -q && \
    apt-get install -y --no-install-recommends \
      at \
      fping \
      graphviz \
      graphviz \
      imagemagick \
      ipmitool \
      libapache2-mod-php5 \
      libvirt-bin \
      mariadb-client \
      mtr-tiny \
      nmap \
      php5-cli \
      php5-gd \
      php5-json \
      php5-ldap \
      php5-mcrypt \
      php5-mysql \
      php5-snmp \
      php-pear \
      pwgen \
      python-mysqldb \
      rrdtool \
      snmp \
      software-properties-common \
      subversion \
      unzip \
      wget \
      whois

RUN mkdir -p \
        /config
        /opt/observium/html \
        /opt/observium/logs \
        /opt/observium/rrd \

# === Webserver - Apache + PHP5

RUN php5enmod mcrypt && \
    a2enmod rewrite

RUN mkdir /etc/service/apache2
COPY bin/service/apache2.sh /etc/service/apache2/run
RUN chmod +x /etc/service/apache2/run

# Boot-time init scripts for phusion/baseimage
COPY bin/my_init.d /etc/my_init.d/
RUN chmod +x /etc/my_init.d/* && \
    chown -R nobody:users /opt/observium && \
    chown -R nobody:users /config && \
    chmod 755 -R /opt/observium && \
    chmod 755 -R /config

# Configure apache2 to serve Observium app
COPY ["conf/apache2.conf", "conf/ports.conf", "/etc/apache2/"]
COPY conf/apache-observium /etc/apache2/sites-available/000-default.conf
RUN rm /etc/apache2/sites-available/default-ssl.conf && \
    echo www-data > /etc/container_environment/APACHE_RUN_USER && \
    echo www-data > /etc/container_environment/APACHE_RUN_GROUP && \
    echo /var/log/apache2 > /etc/container_environment/APACHE_LOG_DIR && \
    echo /var/lock/apache2 > /etc/container_environment/APACHE_LOCK_DIR && \
    echo /var/run/apache2.pid > /etc/container_environment/APACHE_PID_FILE && \
    echo /var/run/apache2 > /etc/container_environment/APACHE_RUN_DIR && \
    chown -R www-data:www-data /var/log/apache2 && \
    rm -Rf /var/www && \
    ln -s /opt/observium/html /var/www

# === Cron and finishing
COPY cron.d /etc/cron.d/

# === phusion/baseimage post-work
# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
