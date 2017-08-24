FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
    openvpn \
    iptables \
    supervisor \
    openresolv \
    && rm -rf /var/lib/apt/lists/*

COPY openvpn.sh /usr/local/bin/openvpn.sh
RUN chmod +x /usr/local/bin/openvpn.sh

COPY openvpn_up.sh /etc/openvpn/openvpn_up.sh
RUN chmod +x /etc/openvpn/openvpn_up.sh

COPY supervisord.conf /etc/supervisor/supervisord.conf

WORKDIR /etc/openvpn

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
