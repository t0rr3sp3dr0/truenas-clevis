#!/bin/bash -e

function ::dialogrc {
	cat <<- EOF
		bindkey formfield TAB FORM_NEXT
		bindkey formfield DOWN FORM_NEXT
		bindkey formfield UP FORM_PREV
		bindkey formbox DOWN FORM_NEXT
		bindkey formbox TAB FORM_NEXT
		bindkey formbox UP FORM_PREV
	EOF
}

function ::passphrase {
	while true
	do
		DIALOG="$(DIALOGRC=<(::dialogrc) dialog --insecure --output-fd '2' --visit-items --passwordform 'Enter your "boot-pool" encryption passphrase.' '10' '70' '0' 'Passphrase:' '1' '10' '' '0' '30' '25' '50' 'Confirm Passphrase:' '2' '10' '' '2' '30' '25' '50' 3>&2 2>&1 1>&3)"
		PASSES="$(sed -n '$=' <<< "${DIALOG}")"
		PASS_0="$(sed -n '1p' <<< "${DIALOG}")"
		PASS_1="$(sed -n '2p' <<< "${DIALOG}")"

		if [ "${PASSES}" -ne 2 ] || [ -z "${PASS_0}" ] || [ -z "${PASS_1}" ]
		then
			dialog --clear --title 'Error' --msgbox 'Empty passphrases are not allowed.' '5' '60' 3>&2 2>&1 1>&3
			continue
		fi

		if [ "${PASS_0}" != "${PASS_1}" ]
		then
			dialog --clear --title 'Error' --msgbox 'Passphrases do not match.' '5' '60' 3>&2 2>&1 1>&3
			continue
		fi

		echo -n "${PASS_0}"
		break
	done
}

D='/run/zfs'
mkdir -m '0700' -p "${D}"

F="${D}/boot-pool.key"
::passphrase > "${F}"

if [ ! -e '/run/truenas-clevis' ]
then
	touch '/run/truenas-clevis'
else
	exec login -f "${USER}"
fi

F='/usr/lib/python3/dist-packages/truenas_installer/install.py'
sed -Ei 's|"compatibility=grub2"|"compatibility=grub2",\n            "-o", "feature@encryption=enabled"|' "${F}"
sed -Ei 's|"-O", "devices=off"|"-O", "devices=off",\n            "-O", "encryption=on",\n            "-O", "keyformat=passphrase",\n            "-O", f"keylocation=file:///run/zfs/{BOOT_POOL}.key"|' "${F}"

D='/usr/local/sbin'
mkdir -p "${D}"

# --- EMBED

F="${D}/chroot"
echo -n 'IyEvYmluL2Jhc2ggLWUKCmNhc2UgIiR7Mn0iIGluCiAgICBncnViLWluc3RhbGwpCiAgICAgICAgLiBncnViLWluc3RhbGwKICAgICAgICA7OwogICAgdXBkYXRlLWdydWIpCiAgICAgICAgLiB1cGRhdGUtZ3J1YgogICAgICAgIDs7CiAgICAqKQogICAgICAgIGV4ZWMgL3Vzci9zYmluL2Nocm9vdCAiJHtAfSIKICAgICAgICA7Owplc2FjCg==' | base64 -d > "${F}"
chmod +x "${F}"

F="${D}/grub-install"
echo -n 'IyEvYmluL2Jhc2ggLWUKCmlmIFsgIiR7MCMjKi99IiA9ICdjaHJvb3QnIF0KdGhlbgogICAgTU5UPSIkezF9IgpmaQoKZm9yIEFSRyBpbiAiJHtAfSIKZG8KICAgIGNhc2UgIiR7QVJHfSIgaW4KICAgICAgICAtLWVmaS1kaXJlY3Rvcnk9KikKICAgICAgICAgICAgRUZJPSIke0FSRyMqPX0iCiAgICAgICAgICAgIDs7CiAgICAgICAgLS10YXJnZXQ9KikKICAgICAgICAgICAgVEdUPSIke0FSRyMqPX0iCiAgICAgICAgICAgIDs7CiAgICAgICAgLVw/fC1WfC0taGVscHwtLXVzYWdlfC0tdmVyc2lvbikKICAgICAgICAgICAgZXhlYyAiL3Vzci9zYmluLyR7MCMjKi99IiAiJHtAfSIKICAgICAgICAgICAgOzsKICAgIGVzYWMKZG9uZQoKY2FzZSAiJHtUR1R9IiBpbgogICAgJycpCiAgICAgICAgIyBOT1AKICAgICAgICA7OwogICAgaTM4Ni1wYykKICAgICAgICBleGl0IDAKICAgICAgICA7OwogICAgeDg2XzY0LWVmaSkKICAgICAgICAjIE5PUAogICAgICAgIDs7CiAgICAqKQogICAgICAgIGV4aXQgMQogICAgICAgIDs7CmVzYWMKCm1rZGlyIC1wICIke01OVH0vJHtFRkk6LWJvb3QvZWZpfS9FRkkvZGViaWFuIgpjdXJsIC1MbyAiJHtNTlR9LyR7RUZJOi1ib290L2VmaX0vRUZJL2RlYmlhbi9ncnVieDY0LmVmaSIgLS1kb2gtdXJsICIke1RSVUVOQVNfQ0xFVklTX0RPSF9VUkw6LWh0dHBzOi8vMS4xLjEuMS9kbnMtcXVlcnl9IiAiJHtUUlVFTkFTX0NMRVZJU19FRklfVVJMOi1odHRwczovL2dpdGh1Yi5jb20vdDBycjNzcDNkcjAvdHJ1ZW5hcy1jbGV2aXMvcmVsZWFzZXMvbGF0ZXN0L2Rvd25sb2FkL0JPT1R4NjQuRUZJfSIK' | base64 -d > "${F}"
chmod +x "${F}"

F="${D}/update-grub"
echo -n 'IyEvYmluL2Jhc2ggLWUKCmlmIFsgIiR7MCMjKi99IiA9ICdjaHJvb3QnIF0KdGhlbgogICAgTU5UPSIkezF9IgpmaQoKIi91c3Ivc2Jpbi8kezAjIyovfSIgIiR7QH0iCgpQT09MPSIkKGZpbmRtbnQgLW4gLW8gJ1NPVVJDRScgLU0gIiR7TU5UfS9ib290L2dydWIiKSIKUE9PTD0iJHtQT09MJSUvKn0iCgpST1dTPSIkKHpmcyBnZXQgLUggLW8gJ25hbWUsdmFsdWUnIC1zICdsb2NhbCcgJ3RydWVuYXM6a2VybmVsX3ZlcnNpb24nIDI+L2Rldi9udWxsKSIKUk9XUz0iJChhd2sgLXYgInJlPV4ke1BPT0x9LyIgJyQxIH4gcmUgeyBwcmludCAkMSAiOyIgJDI7IH07JyA8PDwgIiR7Uk9XU30iKSIKCmZvciBST1cgaW4gJHtST1dTfQpkbwogICAgS0RFVj0iJHtST1clJTsqfSIKICAgIEtWRVI9IiR7Uk9XIyMqO30iCgogICAgUFJFRj0iJChhd2sgJ3sgZ3N1YigvWysuXS8sICJbJl0iKTsgcHJpbnQ7IH0nIDw8PCAiJHtLREVWLyR7UE9PTH19IikiCiAgICBTVUZGPSIkKGF3ayAneyBnc3ViKC9bKy5dLywgIlsmXSIpOyBwcmludDsgfScgPDw8ICIke0tWRVJ9IikiCiAgICBDTURTPSIkKGF3ayAtdiAicmU9XiR7UFJFRn1ALy4rLSR7U1VGRn0kIiAnJDEgPT0gImxpbnV4IiAmJiAkMiB+IHJlIHsgJDEgPSAiIjsgJDIgPSAiIjsgc3ViKCJeIiBGUyAiKyIsICIiKTsgcHJpbnQ7IH0nIDwgIiR7TU5UfS9ib290L2dydWIvZ3J1Yi5jZmciKSIKCiAgICB6ZnMgc2V0ICdvcmcuemZzYm9vdG1lbnU6YWN0aXZlPW9uJyAiJHtLREVWfSIKICAgIHpmcyBzZXQgIm9yZy56ZnNib290bWVudTpjb21tYW5kbGluZT0ke0NNRFN9IiAiJHtLREVWfSIKICAgIHpmcyBzZXQgIm9yZy56ZnNib290bWVudTprZXJuZWw9JHtLVkVSfSIgIiR7S0RFVn0iCmRvbmUK' | base64 -d > "${F}"
chmod +x "${F}"

# ... EMBED

if [ -n "${TRUENAS_CLEVIS_DOH_URL}" ]
then
	echo "TRUENAS_CLEVIS_DOH_URL=${TRUENAS_CLEVIS_DOH_URL}" >> /etc/environment
fi

if [ -n "${TRUENAS_CLEVIS_EFI_URL}" ]
then
	echo "TRUENAS_CLEVIS_EFI_URL=${TRUENAS_CLEVIS_EFI_URL}" >> /etc/environment
fi

exec login -f "${USER}"
