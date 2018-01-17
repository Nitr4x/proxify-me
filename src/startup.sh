#!/bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

inet=`ifconfig | grep inet | head -n1`

echo -e "Container ip address:\n\n${RED}$inet${NC}"

echo -e "\n${GREEN}[+] Setting and starting the SSH service\n${NC}"

/etc/init.d/ssh start&
chmod 600 /root/.ssh/id_rsa
sleep 3
ssh -f -N -D 0.0.0.0:$PROXY_PORT 127.0.0.1

echo -e "\n${GREEN}[+] Filtering external IP access to [$IP_ADDRESSES]${NC}"

IFS='|' read -ra IP_ARRAY <<< $IP_ADDRESSES
for addr in "${IP_ARRAY[@]}"; do
    iptables -A INPUT --src $addr -p tcp --dport $PROXY_PORT -j ACCEPT
done

iptables -A INPUT -p tcp --dport $PROXY_PORT -j REJECT

echo -e "\n${GREEN}[+] Performing VPN tunneling\n${NC}"

for cnf in $(ls /root/vpn); do
    echo -e "$cnf is started"
    openvpn /root/vpn/$cnf > /dev/null 2>&1 &
done

echo -e "\n${GREEN}[+] Proxy open on localhost:$PROXY_PORT\n${NC}"

echo -e "Type ${RED}close${NC} to shutting down the proxy: ---> "

x='';while [[ "$x" != "close" ]]; do read -n5 x; done
