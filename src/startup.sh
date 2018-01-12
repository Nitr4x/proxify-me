#!/bin/sh

echo -e "[+] Setting and starting the SSH service\n"

/etc/init.d/ssh start&
chmod 600 /root/.ssh/id_rsa
sleep 3
ssh -f -N -D 0.0.0.0:1337 127.0.0.1

echo -e "\n[+] Performing VPN tunneling\n"

for cnf in $(ls /root/vpn); do
    echo -e "$cnf is started"
    openvpn /root/vpn/$cnf > /dev/null 2>&1 &
done

echo -e "\n[+] Proxy open on your localhost:1337\n"

echo -e "Type close to shutting down the proxy: ---> "

x='';while [[ "$x" != "close" ]]; do read -n5 x; done
