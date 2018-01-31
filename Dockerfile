FROM debian:latest

RUN apt update
RUN apt -y install openvpn ssh net-tools iptables tor

ADD cnf/sshd_config /etc/ssh/sshd_config
ADD cnf/vpn /root/vpn

ADD ./src/startup.sh /opt/startup.sh

RUN echo "root:YOUR_PASSWORD" | chpasswd

ENTRYPOINT ["/bin/bash", "/opt/startup.sh"]
