#!/bin/bash

KERNEL_VERSION=$(uname -r  | cut -d '-' -f 1)

cd /tmp/linux-${KERNEL_VERSION}

zcat /proc/1/root/proc/config.gz > .config
make all -j$1
make modules_prepare -j$1
make headers_install -j$1
make modules_install -j$1