#!/bin/bash
#
# Installs network weathermap if it isn't in /opt/observium/html and schedules
# it in cron.d
#

HTMLDIR='/opt/observium/html'
WEATHERMAP="$HTMLDIR/weathermap"
C='*/5 *     * * *   root    /opt/observium/html/weathermap/map-poller.php >> /dev/null 2>&1'

# Check env for cue to enable
if [ "$USE_WEATHERMAP" = true ]; then

    # If weathermap isn't in observium htmldir, install it
    if [ ! -d "$WEATHERMAP" ]; then
        cd $HTMLDIR
        git clone https://github.com/laf/weathermap.git weathermap
        chown -hR nobody:users "$WEATHERMAP"
    fi

    # Regardless, schedule map-poller.php
    echo "$C" > /etc/cron.d/weathermap
    restart cron

fi
