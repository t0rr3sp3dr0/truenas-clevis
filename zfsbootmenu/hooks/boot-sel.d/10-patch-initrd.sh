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
echo -n 'IyEvYmluL2Jhc2ggLWUKCmNhc2UgIiR7Mn0iIGluCiAgICBncnViLWluc3RhbGwpCiAgICAgICAgLiBncnViLWluc3RhbGwKICAgICAgICA7OwogICAgdXBkYXRlLWdydWIpCiAgICAgICAgLiB1cGRhdGUtZ3J1YgogICAgICAgIDs7CiAgICAqKQogICAgICAgIGV4ZWMgL3Vzci9zYmluL2Nocm9vdCAiJHtAfSIKICAgICAgICA7Owplc2FjCg==' | base64 -d > "\${F}"
chmod +x "\${F}"

F="\${D}/grub-install"
echo -n 'IyEvYmluL2Jhc2ggLWUKCmlmIFsgIiR7MCMjKi99IiA9ICdjaHJvb3QnIF0KdGhlbgogICAgTU5UPSIkezF9IgpmaQoKZm9yIEFSRyBpbiAiJHtAfSIKZG8KICAgIGNhc2UgIiR7QVJHfSIgaW4KICAgICAgICAtLWVmaS1kaXJlY3Rvcnk9KikKICAgICAgICAgICAgRUZJPSIke0FSRyMqPX0iCiAgICAgICAgICAgIDs7CiAgICAgICAgLS10YXJnZXQ9KikKICAgICAgICAgICAgVEdUPSIke0FSRyMqPX0iCiAgICAgICAgICAgIDs7CiAgICAgICAgLVw/fC1WfC0taGVscHwtLXVzYWdlfC0tdmVyc2lvbikKICAgICAgICAgICAgZXhlYyAiL3Vzci9zYmluLyR7MCMjKi99IiAiJHtAfSIKICAgICAgICAgICAgOzsKICAgIGVzYWMKZG9uZQoKY2FzZSAiJHtUR1R9IiBpbgogICAgJycpCiAgICAgICAgIyBOT1AKICAgICAgICA7OwogICAgaTM4Ni1wYykKICAgICAgICBleGl0IDAKICAgICAgICA7OwogICAgeDg2XzY0LWVmaSkKICAgICAgICAjIE5PUAogICAgICAgIDs7CiAgICAqKQogICAgICAgIGV4aXQgMQogICAgICAgIDs7CmVzYWMKCm1rZGlyIC1wICIke01OVH0vJHtFRkk6LWJvb3QvZWZpfS9FRkkvZGViaWFuIgpjdXJsIC1MbyAiJHtNTlR9LyR7RUZJOi1ib290L2VmaX0vRUZJL2RlYmlhbi9ncnVieDY0LmVmaSIgLS1kb2gtdXJsICIke1RSVUVOQVNfQ0xFVklTX0RPSF9VUkw6LWh0dHBzOi8vMS4xLjEuMS9kbnMtcXVlcnl9IiAiJHtUUlVFTkFTX0NMRVZJU19FRklfVVJMOi1odHRwczovL2dpdGh1Yi5jb20vdDBycjNzcDNkcjAvdHJ1ZW5hcy1jbGV2aXMvcmVsZWFzZXMvbGF0ZXN0L2Rvd25sb2FkL0JPT1R4NjQuRUZJfSIK' | base64 -d > "\${F}"
chmod +x "\${F}"

F="\${D}/update-grub"
echo -n 'IyEvYmluL2Jhc2ggLWUKCmlmIFsgIiR7MCMjKi99IiA9ICdjaHJvb3QnIF0KdGhlbgogICAgTU5UPSIkezF9IgpmaQoKIi91c3Ivc2Jpbi8kezAjIyovfSIgIiR7QH0iCgpQT09MPSIkKGZpbmRtbnQgLW4gLW8gJ1NPVVJDRScgLU0gIiR7TU5UfS9ib290L2dydWIiKSIKUE9PTD0iJHtQT09MJSUvKn0iCgpST1dTPSIkKHpmcyBnZXQgLUggLW8gJ25hbWUsdmFsdWUnIC1zICdsb2NhbCcgJ3RydWVuYXM6a2VybmVsX3ZlcnNpb24nIDI+L2Rldi9udWxsKSIKUk9XUz0iJChhd2sgLXYgInJlPV4ke1BPT0x9LyIgJyQxIH4gcmUgeyBwcmludCAkMSAiOyIgJDI7IH07JyA8PDwgIiR7Uk9XU30iKSIKCmZvciBST1cgaW4gJHtST1dTfQpkbwogICAgS0RFVj0iJHtST1clJTsqfSIKICAgIEtWRVI9IiR7Uk9XIyMqO30iCgogICAgUFJFRj0iJChhd2sgJ3sgZ3N1YigvWysuXS8sICJbJl0iKTsgcHJpbnQ7IH0nIDw8PCAiJHtLREVWLyR7UE9PTH19IikiCiAgICBTVUZGPSIkKGF3ayAneyBnc3ViKC9bKy5dLywgIlsmXSIpOyBwcmludDsgfScgPDw8ICIke0tWRVJ9IikiCiAgICBDTURTPSIkKGF3ayAtdiAicmU9XiR7UFJFRn1ALy4rLSR7U1VGRn0kIiAnJDEgPT0gImxpbnV4IiAmJiAkMiB+IHJlIHsgJDEgPSAiIjsgJDIgPSAiIjsgc3ViKCJeIiBGUyAiKyIsICIiKTsgcHJpbnQ7IH0nIDwgIiR7TU5UfS9ib290L2dydWIvZ3J1Yi5jZmciKSIKCiAgICB6ZnMgc2V0ICdvcmcuemZzYm9vdG1lbnU6YWN0aXZlPW9uJyAiJHtLREVWfSIKICAgIHpmcyBzZXQgIm9yZy56ZnNib290bWVudTpjb21tYW5kbGluZT0ke0NNRFN9IiAiJHtLREVWfSIKICAgIHpmcyBzZXQgIm9yZy56ZnNib290bWVudTprZXJuZWw9JHtLVkVSfSIgIiR7S0RFVn0iCmRvbmUK' | base64 -d > "\${F}"
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
