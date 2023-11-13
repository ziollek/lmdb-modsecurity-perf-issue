#!/bin/bash

KERNEL_VERSION=$(uname -r  | cut -d '-' -f 1)

cd /tmp
curl -o linux-${KERNEL_VERSION}.tar.gz https://mirrors.edge.kernel.org/pub/linux/kernel/v${KERNEL_VERSION:0:1}.x/linux-${KERNEL_VERSION}.tar.gz
tar zxf linux-${KERNEL_VERSION}.tar.gz
