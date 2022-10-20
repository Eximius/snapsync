#!/usr/bin/env bash

set -e

default_dev=$(ip r | grep '^default via' | cut -d ' ' -f 5)

if [ "$default_dev" == '' ]; then
  # Disconnected
  echo "State: Disconnected"
  systemctl stop snapsync-is-connection-unmetered.service
  exit 0
fi

if [ "$(nmcli -g general.metered dev show "$default_dev" | cut -d ' ' -f 1)" == 'no' ]; then
  echo "State: Unmetered"
  systemctl start snapsync-is-connection-unmetered.service
else
  echo "State: Metered"
  systemctl stop snapsync-is-connection-unmetered.service
fi


