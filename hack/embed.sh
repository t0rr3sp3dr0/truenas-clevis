#!/bin/bash -e

D="${1}"
F="${2}"
S="${3}"

PRO="$(awk '!--NR,/^# [-]{3} EMBED$/;' < "${F}")"
EPI="$(awk '/^# [.]{3} EMBED$/,0;' < "${F}")"

exec > "${F}"

echo "${PRO}"

echo

for BIN in "${D}"/*
do
	cat <<- EOF
		F="${S}\${D}/${BIN##*/}"
		echo -n '$(base64 < "${BIN}" | tr -d '\n')' | base64 -d > "${S}\${F}"
		chmod +x "${S}\${F}"

	EOF
done

echo "${EPI}"
