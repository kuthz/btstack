#!/bin/sh
echo 'Block everything at start'
# Flush all rules
iptables -F

# Set default policy
iptables --policy FORWARD DROP
iptables --policy OUTPUT  DROP
iptables --policy INPUT   DROP

if [ ! -z "$OPENVPN_CONFIG" ]
then
 if [ -f profile/"${OPENVPN_CONFIG}".ovpn ]
 then
  echo "Starting OpenVPN using config ${OPENVPN_CONFIG}.ovpn"
  OPENVPN_CONFIG=profile/${OPENVPN_CONFIG}.ovpn
 else
  echo "Supplied config ${OPENVPN_CONFIG}.ovpn could not be found."
  exit 1
 fi
else
 echo "No VPN configuration provided."
 exit 1
fi

if [ -f profile/.credentials ]
 then
   OPENVPN_AUTH="--auth-user-pass profile/.credentials"
fi

eval $(awk '/remote / { split($0,a," "); print "OPENVPN_SERVER_IP="a[2]"\nOPENVPN_SERVER_PORT="a[3]"" }' $OPENVPN_CONFIG)
eval $(awk '/proto/ { split($0,a," "); print "OPENVPN_SERVER_PROTO="a[2]"" }' $OPENVPN_CONFIG)

echo "Configure to allow $OPENVPN_SERVER_IP:$OPENVPN_SERVER_PORT:$OPENVPN_SERVER_PROTO only"

#Allow DNS by default to support openvpn configured with DNS, it will be block when openvpn connection up
iptables -A OUTPUT -p udp -o eth0 --dport 53 -j ACCEPT

# Allow VPN connection on ETH0
iptables -A OUTPUT -o eth0 -d $OPENVPN_SERVER_IP -p $OPENVPN_SERVER_PROTO --dport $OPENVPN_SERVER_PORT -j ACCEPT
iptables -A INPUT  -i eth0 -s $OPENVPN_SERVER_IP -p $OPENVPN_SERVER_PROTO --sport $OPENVPN_SERVER_PORT -j ACCEPT

# Allow ALL on TUN0
iptables -A OUTPUT -o tun0 -d 0.0.0.0/0 -j ACCEPT
iptables -A INPUT  -i tun0 -s 0.0.0.0/0 -j ACCEPT

# Allow ALL on LOOPBACK
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT  -i lo -j ACCEPT

eval $(/sbin/ip r l m 0.0.0.0 | awk '{if($5!="tun0"){print "GW="$3"\nINT="$5; exit}}')
if [ -n "${GW-}" -a -n "${INT-}" ]; then
    # Allow communication from the docker gateway, needed for docker MAC
    iptables -A OUTPUT -o "$INT" -d "$GW" -j ACCEPT
    iptables -A INPUT  -i "$INT" -s "$GW" -j ACCEPT

    if [ -n "${LOCAL_NETWORK-}" ]; then
        echo "adding route to local network $LOCAL_NETWORK via $GW dev $INT"
        /sbin/ip r a "$LOCAL_NETWORK" via "$GW" dev "$INT"
        # Allow private networks on eth0
        iptables -A OUTPUT -o "$INT" -d $LOCAL_NETWORK -j ACCEPT
        iptables -A INPUT  -i "$INT" -s $LOCAL_NETWORK -j ACCEPT
    fi
fi

openvpn $OPENVPN_OPTS --script-security 2 --up /etc/openvpn/openvpn_up.sh --config "$OPENVPN_CONFIG" $OPENVPN_AUTH
