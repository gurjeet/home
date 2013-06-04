#!/bin/bash

# Complimentary to disbale_hyperthreading.sh

for CPU_PATH in /sys/devices/system/cpu/cpu[0-9]*; do
   echo 1 > $CPU_PATH/online
done
