#!/bin/sh
set -e

D='/run/zfs'
F="${D}/boot-pool.key"

if [ ! -e "${F}" ]
then
    mkdir -m '0700' -p "${D}"
    echo -n 'nimda_saneurt' > "${F}"
fi
