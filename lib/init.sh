#!/bin/bash

export BASE="${BASE:-/srv/mirror.unej.ac.id/status}"

NODE="${NODE:-mirror.unej.ac.id}"

. $BASE/etc/config.sh

[ -f $BASE/etc/conf.d/$HOST.conf ] && . $BASE/etc/conf.d/$HOST.conf


