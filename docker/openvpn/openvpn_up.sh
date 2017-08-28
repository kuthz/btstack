#!/usr/bin/env bash
echo 'Update resolv.conf to use VPN dns servers'
/etc/openvpn/update-resolv-conf || true
resolvconf -u || true
