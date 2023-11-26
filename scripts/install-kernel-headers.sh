#!/bin/bash

KERNEL_VERSION=$(uname -r  | cut -d '-' -f 1)

cd /tmp/linux-${KERNEL_VERSION}

zcat /proc/1/root/proc/config.gz > .config
sed -ri '/CONFIG_MODULE_SIG_KEY/s/=.+/=""/g' .config
make all
make modules_prepare
make headers_install
make modules_install
