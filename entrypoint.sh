#!/bin/sh

case "$1" in 
    tftp-server)
        [ "$TFTPD_DIR" = "" ] && TFTPD_DIR=/tftp
        mkdir -p "$TFTPD_DIR"
        chmod -R o+r "$TFTPD_DIR"
        echo "Starting TFTP Server"
        exec /usr/sbin/in.tftpd -s "$TFTPD_DIR" -vv -L
        ;;
    dhcp-server)
        DHCPCONF=/etc/dhcp/dhcpd.conf
        
        if [ "$INTERFACES" = "" ]
        then
            echo "You must configure INTERFACES env var with one of these :" >&2
            ifconfig |grep -oE "^[^ ]*"|grep -v lo | sed 's/^/  - /g'|sort  >&2 
            exit 1
        fi
        if [ "$IPXE_URL" = "" ]
        then
            echo "You must configure IPXE_URL env var with http url to your iPXE script" >&2
            echo 'Example : IPXE_URL=http://10.1.1.1:81/ipxe.php?mac=${net0/mac}' >&2
            exit 2
        fi
        
        [ "$DHCP_DEFAULT_LEASE_TIME" = "" ] && DHCP_DEFAULT_LEASE_TIME=600
        [ "$DHCP_MAX_LEASE_TIME" = "" ] && DHCP_MAX_LEASE_TIME=7200
        [ "$DHCP_NET" = "" ] && DHCP_NET=10.1.1.0
        [ "$DHCP_MASK" = "" ] && DHCP_MASK=255.255.255.0
        [ "$DHCP_START" = "" ] && DHCP_START=10.1.1.100
        [ "$DHCP_STOP" = "" ] && DHCP_STOP=10.1.1.199
        [ "$DHCP_GW" = "" ] && DHCP_GW=10.1.1.254
        [ "$DHCP_DNS" = "" ] && DHCP_DNS=8.8.8.8
        
        (
            echo "ddns-update-style none;"
            echo "default-lease-time $DHCP_DEFAULT_LEASE_TIME;"
            echo "max-lease-time $DHCP_MAX_LEASE_TIME;"
            echo "authoritative;"
            echo ""
            echo "subnet $DHCP_NET netmask $DHCP_MASK {"
            echo "  range $DHCP_START $DHCP_STOP;"
            echo "  option domain-name-servers $DHCP_DNS;"
            echo "  option routers $DHCP_GW;"
            echo "  if exists user-class and option user-class = \"iPXE\" {"
            echo "      filename \"$IPXE_URL\";"
            echo "  } else {"
            echo "    filename \"undionly.kpxe\";"
            echo "  }"
            echo "}"
        ) > $DHCPCONF
        touch /var/lib/dhcp/dhcpd.leases
        exec /usr/sbin/dhcpd -4 -f -d --no-pid -cf /etc/dhcp/dhcpd.conf $INTERFACES
        ;;
    *) 
        exec $@
esac