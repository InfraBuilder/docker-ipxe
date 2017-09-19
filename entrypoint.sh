#!/bin/sh

[ "$TFTPD_DIR" = "" ] && TFTPD_DIR=/tftp

case "$1" in 
    tftp-server)
        mkdir -p "$TFTPD_DIR"
        chmod -R o+r "$TFTPD_DIR"
        echo "Starting TFTP Server"
        exec /usr/sbin/in.tftpd -s "$TFTPD_DIR" -vv -L
        ;;
    dhcp-serve)
        echo "dhcp-server not implemented"
        ;;
    *) 
        exec $@
esac