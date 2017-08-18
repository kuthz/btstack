#!/usr/bin/env bash
echo 'Remove iptables DNS rule'
iptables -D OUTPUT -p udp -o eth0 --dport 53 -j ACCEPT
