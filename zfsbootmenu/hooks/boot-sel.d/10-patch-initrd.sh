#!/bin/sh
set -e

echo $'Patching \033[1;33m'"${ZBM_SELECTED_INITRAMFS}"$'\033[0m for \033[0;36m'"${ZBM_SELECTED_BE}"$'\033[0m ...' 1>&2

RUNZBM='/run/zbm'
mkdir -p "${RUNZBM}"

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

F="\${D}/chroot"
echo '#!/bin/bash -e' > "\${F}"
echo '[[ "\${2}" = "grub-install" ]] && mkdir -p "\${1}/boot/efi/EFI/debian" && curl -Lo "\${1}/boot/efi/EFI/debian/grubx64.efi" "https://github.com/t0rr3sp3dr0/truenas-clevis/releases/latest/download/BOOTx64.EFI" && exec /usr/sbin/chroot "\${1}" grub-install --version || exec /usr/sbin/chroot "\${@}"' >> "\${F}"
chmod +x "\${F}"

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
