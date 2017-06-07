FROM ubuntu:16.04

RUN apt-get update && apt-get -y install openvpn iptables

ADD start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

WORKDIR /etc/openvpn

CMD ["start.sh"]
