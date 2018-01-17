FROM debian:latest

RUN apt update
RUN apt -y install openvpn ssh net-tools iptables

ADD cnf/sshd_config /etc/ssh/sshd_config
ADD cnf/.ssh /root/.ssh
ADD cnf/vpn /root/vpn

ADD ./src/startup.sh /opt/startup.sh

ENTRYPOINT ["/bin/bash", "/opt/startup.sh"]
