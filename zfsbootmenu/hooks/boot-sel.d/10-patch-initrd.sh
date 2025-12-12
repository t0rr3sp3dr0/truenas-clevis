#!/bin/sh
set -e

echo $'Patching \033[1;33m'"${ZBM_SELECTED_INITRAMFS}"$'\033[0m for \033[0;36m'"${ZBM_SELECTED_BE}"$'\033[0m ...' 1>&2

RUNZBM='/run/zbm'
mkdir -m '0700' -p "${RUNZBM}"

INITRD="${ZBM_SELECTED_MOUNTPOINT}${ZBM_SELECTED_INITRAMFS}"
BLOCKS="$(cpio -t < "${INITRD}" 2>&1 | awk '$2 == "blocks" { print $1; }')"
RDCPIO="${RUNZBM}/initrd.cpio"
dd if="${INITRD}" skip="${BLOCKS}" bs='512' status='none' | zstd -d > "${RDCPIO}"

cd "$(mktemp -d)"

D='etc/zfs/initramfs-tools-load-key.d'
mkdir -p "${D}"

F="${D}/10-rebind-runzfs.sh"
cat << EOF > "${F}"
#!/bin/sh
set -e

mkdir -p '/run/zfs'
mount --move '/run' '/tmp'
mount --bind '/run/zfs' '/tmp/zfs'
mount --move '/tmp' '/run'
EOF
chmod +x "${F}"

D='run/zfs'
mkdir -p "${D}"

for F in /run/zfs/*.key
do
    cp -f "${F}" "${D}"
done

D='scripts/local-bottom'
mkdir -p "${D}"

F="${D}/ORDER"
cpio -i --quiet "${F}" < "${RDCPIO}"
cat << EOF >> "${F}"
/scripts/local-bottom/patch-rootfs "\$@"
[ -e /conf/param.conf ] && . /conf/param.conf
/scripts/local-bottom/patch-systemd-system-conf "\$@"
[ -e /conf/param.conf ] && . /conf/param.conf
EOF
sed -i "s|${F}|${D}/.....|" "${RDCPIO}"

F="${D}/patch-rootfs"
cat << EOF > "${F}"
#!/bin/sh
set -e

MNT='/root'

D="\${MNT}/root/.local/sbin"
mkdir -p "\${D}"

# --- EMBED

F="\${D}/chroot"
echo -n 'IyEvYmluL2Jhc2ggLWUKCmNhc2UgIiR7Mn0iIGluCiAgICBncnViLWluc3RhbGwpCiAgICAgICAgLiBncnViLWluc3RhbGwKICAgICAgICA7OwoKICAgIHVwZGF0ZS1ncnViKQogICAgICAgIC4gdXBkYXRlLWdydWIKICAgICAgICA7OwoKICAgICopCiAgICAgICAgZXhlYyAvdXNyL3NiaW4vY2hyb290ICIke0B9IgogICAgICAgIDs7CmVzYWMK' | base64 -d > "\${F}"
chmod +x "\${F}"

F="\${D}/grub-install"
echo -n 'IyEvYmluL2Jhc2ggLWUKCmlmIFsgIiR7MCMjKi99IiA9ICdjaHJvb3QnIF0KdGhlbgogICAgTU5UPSIkezF9IgoKICAgIGlmIFsgIiR7M30iID0gJy0tdmVyc2lvbicgXQogICAgdGhlbgogICAgICAgIGV4ZWMgL3Vzci9zYmluL2Nocm9vdCAiJHtAfSIKICAgIGZpCmVsc2UKICAgIGlmIFsgIiR7MX0iID0gJy0tdmVyc2lvbicgXQogICAgdGhlbgogICAgICAgIGV4ZWMgL3Vzci9zYmluL2dydWItaW5zdGFsbCAiJHtAfSIKICAgIGZpCmZpCgpta2RpciAtcCAiJHtNTlR9L2Jvb3QvZWZpL0VGSS9kZWJpYW4iCmN1cmwgLUxvICIke01OVH0vYm9vdC9lZmkvRUZJL2RlYmlhbi9ncnVieDY0LmVmaSIgLS1kb2gtdXJsICIke1RSVUVOQVNfQ0xFVklTX0RPSF9VUkw6LWh0dHBzOi8vMS4xLjEuMS9kbnMtcXVlcnl9IiAiJHtUUlVFTkFTX0NMRVZJU19FRklfVVJMOi1odHRwczovL2dpdGh1Yi5jb20vdDBycjNzcDNkcjAvdHJ1ZW5hcy1jbGV2aXMvcmVsZWFzZXMvbGF0ZXN0L2Rvd25sb2FkL0JPT1R4NjQuRUZJfSIK' | base64 -d > "\${F}"
chmod +x "\${F}"

F="\${D}/update-grub"
echo -n 'IyEvYmluL2Jhc2ggLWUKCmlmIFsgIiR7MCMjKi99IiA9ICdjaHJvb3QnIF0KdGhlbgogICAgTU5UPSIkezF9IgoKICAgIC91c3Ivc2Jpbi9jaHJvb3QgIiR7QH0iCmVsc2UKICAgIC91c3Ivc2Jpbi91cGRhdGUtZ3J1YiAiJHtAfSIKZmkKClBPT0w9IiQoZmluZG1udCAtbiAtbyAnU09VUkNFJyAtTSAiJHtNTlR9L2Jvb3QvZ3J1YiIpIgpQT09MPSIke1BPT0wlJS8qfSIKClJPV1M9IiQoemZzIGdldCAtSCAtbyAnbmFtZSx2YWx1ZScgLXMgJ2xvY2FsJyAndHJ1ZW5hczprZXJuZWxfdmVyc2lvbicgMj4vZGV2L251bGwpIgpST1dTPSIkKGF3ayAtdiAicmU9XiR7UE9PTH0vIiAnJDEgfiByZSB7IHByaW50ICQxICI7IiAkMjsgfTsnIDw8PCAiJHtST1dTfSIpIgoKZm9yIFJPVyBpbiAke1JPV1N9CmRvCiAgICBLREVWPSIke1JPVyUlOyp9IgogICAgS1ZFUj0iJHtST1cjIyo7fSIKCiAgICBQUkVGPSIkKGF3ayAneyBnc3ViKC9bKy5dLywgIlsmXSIpOyBwcmludDsgfScgPDw8ICIke0tERVYvJHtQT09MfX0iKSIKICAgIFNVRkY9IiQoYXdrICd7IGdzdWIoL1srLl0vLCAiWyZdIik7IHByaW50OyB9JyA8PDwgIiR7S1ZFUn0iKSIKICAgIENNRFM9IiQoYXdrIC12ICJyZT1eJHtQUkVGfUAvListJHtTVUZGfSQiICckMSA9PSAibGludXgiICYmICQyIH4gcmUgeyAkMSA9ICIiOyAkMiA9ICIiOyBzdWIoIl4iIEZTICIrIiwgIiIpOyBwcmludDsgfScgPCAiJHtNTlR9L2Jvb3QvZ3J1Yi9ncnViLmNmZyIpIgoKICAgIHpmcyBzZXQgJ29yZy56ZnNib290bWVudTphY3RpdmU9b24nICIke0tERVZ9IgogICAgemZzIHNldCAib3JnLnpmc2Jvb3RtZW51OmNvbW1hbmRsaW5lPSR7Q01EU30iICIke0tERVZ9IgogICAgemZzIHNldCAib3JnLnpmc2Jvb3RtZW51Omtlcm5lbD0ke0tWRVJ9IiAiJHtLREVWfSIKZG9uZQo=' | base64 -d > "\${F}"
chmod +x "\${F}"

# ... EMBED

D="\${MNT}/root/.local/bin"
mkdir -p "\${D}"

F="\${D}/clevis"
echo '#!/bin/bash -e' > "\${F}"
echo 'echo -e "\${0##*/}: This tool needs to be executed from ZFSBootMenu." && exit 2' >> "\${F}"
chmod +x "\${F}"
EOF
chmod +x "${F}"

F="${D}/patch-systemd-system-conf"
cat << EOF > "${F}"
#!/bin/sh
set -e

MNT='/root'

sed -i 's|#DefaultEnvironment=|DefaultEnvironment="PATH=/root/.local/sbin:/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"|' "\${MNT}/etc/systemd/system.conf"
EOF
chmod +x "${F}"

find . -print0 | cpio -o -R '0:0' -O "${RDCPIO}" -H 'newc' -A -0 --quiet --device-independent

rm -Rf *
