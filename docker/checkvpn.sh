#!/usr/bin/env bash

while true; do
    VPN_STATUS=$(cat /sys/class/net/tun0/carrier 2> /dev/null)
    if [[ ${VPN_STATUS} -eq 0 ]]; then
        sleep 2  # network not yet up
    else
        echo "VPN is up!!!"
        # Launch default entry point
        /init
    fi
done