#/system/glibc/bin/sh
set -x

echo N > /sys/class/net/wwan1/qmi/raw_ip
ip link set wwan1 down
ip link set wwan1 mtu 16384
echo Y > /sys/class/net/wwan1/qmi/raw_ip

echo 112 > /sys/class/net/wwan1/qmi/add_mux
exit 0
qmicli -p -d /dev/cdc-wdm1 --dms-get-model


qmicli -p -d /dev/cdc-wdm1 --wda-set-data-format=link-layer-protocol=raw-ip,ul-protocol=qmap,dl-protocol=qmap,dl-max-datagrams=32,dl-datagram-max-size=16384

qmicli -p -d /dev/cdc-wdm1 --wds-noop --client-no-release-cid

qmicli -p -d /dev/cdc-wdm1 --wds-bind-mux-data-port=mux-id=112,ep-iface-number=2,ep-type=hsusb --client-no-release-cid --client-cid=15


qmicli -p -d /dev/cdc-wdm1 --wds-create-profile=3gpp,apn=mcinet,pdp-type=IP --client-no-release-cid --client-cid=15

exit 0
qmicli -p -d /dev/cdc-wdm1 --wds-start-network=3gpp-profile=12 --client-no-release-cid --client-cid=15

#----

qmicli -p -d /dev/cdc-wdm1 --wds-get-current-settings --client-no-release-cid --client-cid=15

ip addr add 102.154.235.90/30 dev qmimux0
ip link set wwan1 up
ip link set qmimux0 mtu 1500 up

ip route add default via 102.154.235.89

export WWAN=qmimux0
export IP=21.186.97.7

ip r add default dev $WWAN
ndc resolver setnetdns $WWAN 8.8.8.8 8.8.4.4
ndc network create 1
ndc network interface add 1 $WWAN
ndc network route add 1 $WWAN 0.0.0.0/0 $IP
ndc resolver setnetdns 1 $WWAN 8.8.8.8 8.8.4.4
ndc network default set 1






