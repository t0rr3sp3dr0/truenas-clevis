#!/bin/sh
set -e

D='/run/zfs'
F="${D}/boot-pool.key"

if [ ! -e "${F}" ]
then
    mkdir -p "${D}"
    echo -n 'nimda_saneurt' > "${F}"
fi
