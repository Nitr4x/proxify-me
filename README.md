# Proxify-me

Docker container whose aim is to provide a simple way to deploy a SOCKS proxy platform using SSH.

# Customization

This container allows mounting VPN tunnels. To do so, place your openvpn configurations in the *cnf/vpn* folder and/or modify the startup.sh script in order to fit your needs.

# Build

To build the container, just use this command:

```bash
docker build -t proxify .
```

Docker will download the Debian image and then execute the installation steps.

> Be patient, the process can be quite long the first time.

# Run

Once the build process is over, get and enjoy your new proxified platform by settings your proxy to 127.0.0.1:1337 :)

```bash
docker run --rm -it -p 1337:1337 --privileged --sysctl net.ipv6.conf.all.disable_ipv6=0 --name proxify proxify
```
