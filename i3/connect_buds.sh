#!/bin/bash
echo -e "power on\ndisconnect {{buds_address}}" | bluetoothctl
sleep 1
echo -e "connect {{buds_address}}" | bluetoothctl
