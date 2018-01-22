#!/bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

inet=`ifconfig | grep inet | head -n1`

echo -e "Container ip address:\n\n${RED}$inet${NC}"

echo -e "\n${GREEN}[+] Configuring network forwarding${NC}\n"

sysctl -w net.ipv6.conf.all.disable_ipv6=0
sysctl -w net.ipv4.conf.eth0.route_localnet=1

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

echo -e "\n${GREEN}[+] Proxy open on localhost:$PROXY_PORT\n${NC}"

echo -e "Type ${RED}help${NC} to display the menu: --->\n"

function help {
    echo -e "${GREEN}\nifconfig\nvpn\ntor\nquit\n${NC}"
}

while :
do
    read input

    case "$input" in
        vpn)
            echo -e "\n${GREEN}Mounting VPN tunneling${RED} [This could take a while. Be patient]${NC}\n" && openvpn /root/vpn/`ls /root/vpn/`
            ;;
        tor)
            echo -e "\n${GREEN}Mounting TOR circuit${NC}\n"
            iptables -t nat -I PREROUTING -p tcp -d 172.17.0.0/24 --dport 1337 -j DNAT --to-destination 127.0.0.1:9050
            tor
            iptables -t nat -D PREROUTING -p tcp -d 172.17.0.0/24 --dport 1337 -j DNAT --to-destination 127.0.0.1:9050
            ;;
        ifconfig)
            echo -e "\n${GREEN}$(ifconfig)\n${NC}"
            ;;
        quit)
            exit 1
            ;;
        help)
            help
            ;;
        *)
            echo -e "\n${RED}Unkown command\n${NC}"
            ;;
    esac
done
