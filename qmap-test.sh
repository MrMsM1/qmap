#/system/glibc/bin/sh

source /glibc-env
set -x

if [ -z $1 ]; then
    echo Usage: $0 /dev/cdc-wdmX
    echo "       Where X is the modem index '(0-4)'"
    exit 1
fi
# export WWAN=wwan0
# export DEV=/dev/cdc-wdm0

DEV=$1
WWAN=$(qmicli --device=$DEV --device-open-proxy --get-wwan-iface)
#DATAGRAM_MAX_SZ=31744
DATAGRAM_MAX_SZ=16384
#DATAGRAM_MAX_SZ=$((31744/4))

echo Network is: $WWAN
if [ -z $WWAN ]; then 
    echo "Could not find wwan device!"
    exit 1
fi

echo N > /sys/class/net/$WWAN/qmi/raw_ip
ip link set $WWAN down
ip link set $WWAN mtu $DATAGRAM_MAX_SZ
echo Y > /sys/class/net/$WWAN/qmi/raw_ip

echo 112 > /sys/class/net/$WWAN/qmi/add_mux
# exit 0
qmicli -p -d $DEV --dms-get-model
qmicli -p -d $DEV --dms-get-model


qmicli -p -d $DEV --wda-set-data-format=link-layer-protocol=raw-ip,ul-protocol=qmap,dl-protocol=qmap,dl-max-datagrams=32,dl-datagram-max-size=$DATAGRAM_MAX_SZ

CID=$(qmicli -p -d $DEV --wds-noop --client-no-release-cid | awk -F : '/CID/{print $2}' | awk -F \' '{print $2}')
echo CID = $CID

qmicli -p -d $DEV --wds-bind-mux-data-port=mux-id=112,ep-iface-number=2,ep-type=hsusb --client-no-release-cid --client-cid=$CID

qmicli -p -d /dev/cdc-wdm0 --wds-delete-profile=3gpp,9
PROFILE_INDEX=$(qmicli -p -d $DEV --wds-create-profile=3gpp,apn=mcinet,pdp-type=IP --client-no-release-cid --client-cid=$CID | awk -F : '/Profile index/{print $2}' | awk -F \' '{print $2}')
echo PROFILE_INDEX = $PROFILE_INDEX
# exit 0
# Change the profile index in the following command
qmicli -p -d $DEV --wds-start-network=3gpp-profile=$PROFILE_INDEX --client-no-release-cid --client-cid=$CID

#----

IP=$(qmicli -p -d $DEV --wds-get-current-settings --client-no-release-cid --client-cid=$CID | awk -F : '/IPv4 address/ {print $2}')
NETMASK=$(qmicli -p -d $DEV --wds-get-current-settings --client-no-release-cid --client-cid=$CID | awk -F : '/IPv4 subnet mask/ {print $2}' | xargs)
GATEWAY=$(qmicli -p -d $DEV --wds-get-current-settings --client-no-release-cid --client-cid=$CID | awk -F : '/IPv4 gateway address/ {print $2}')

echo IP = $IP
echo NETMASK = $NETMASK
echo GATEWAY = $GATEWAY
# exit 0
# ip addr add 21.207.52.171/29 dev qmimux0
ip addr add $IP/$NETMASK dev qmimux0
ip link set $WWAN up
ip link set qmimux0 mtu 1500 up

ip route add default via $GATEWAY
exit 0

# Export to android

ndc resolver setnetdns qmimux0 8.8.8.8 8.8.4.4

ndc network create 1
ndc network interface add 1 qmimux0
ndc network route add 1 qmimux0 0.0.0.0/0 $IP
ndc resolver setnetdns 1 qmimux0 8.8.8.8 8.8.4.4
ndc network default set 1





