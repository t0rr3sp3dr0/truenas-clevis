#!/bin/sh
set -e

KEXEC='/zbm/bin/kexec'

cat << EOF > "${KEXEC}"
#!/bin/sh
set -e

INITRD='/run/initrd.cpio'

if [ -e "\${INITRD}" ]
then
    for ARG in "\${@}"
    do
        case "\${ARG}" in
            --initrd=*)
                set -- "\${@}" "--initrd=\${INITRD}"
                ;;
            *)
                set -- "\${@}" "\${ARG}"
                ;;
        esac

        shift
    done
fi

exec /usr/sbin/kexec "\${@}"
EOF

chmod +x "${KEXEC}"
