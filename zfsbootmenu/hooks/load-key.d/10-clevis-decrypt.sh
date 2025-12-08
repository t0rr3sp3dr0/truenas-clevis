#!/bin/sh
set -e

DIR='/run/zfs'
mkdir -p "${DIR}"

ROOTS="$(zfs get -H -o 'name,value' 'encryptionroot' 2>/dev/null)"
ROOTS="$(awk '$1 == $2 { print $2; };' <<< "${ROOTS}")"

for ROOT in ${ROOTS}
do
    SLOTS="$(zfs get -H -o 'value' 'io.github.latchset.clevis:slots' "${ROOT}" 2>/dev/null)"
    SLOTS="${SLOTS:-0}"

    KEY="${DIR}/${ROOT//\//:}.key"

    for (( I=0; I<SLOTS; I++ ))
    do
        SLOT_IDX=$(printf '%02X' "${I}")

        PARTS="$(zfs get -H -o 'value' "io.github.latchset.clevis:slot_${SLOT_IDX}_parts" "${ROOT}" 2>/dev/null)"
        PARTS="${PARTS:-0}"

        JWE=''

        for (( J=0; J<PARTS; J++ ))
        do
            PART_IDX=$(printf '%02X' "${J}")

            PART="$(zfs get -H -o 'value' "io.github.latchset.clevis:slot_${SLOT_IDX}_part_${PART_IDX}" "${ROOT}" 2>/dev/null)"

            JWE="${JWE}${PART}"
        done

        if [ -n "${JWE}" ]
        then
            echo -n "${JWE}" | clevis decrypt > "${KEY}" || rm -f "${KEY}"
        fi

        if [ -e "${KEY}" ]
        then
            break
        fi
    done
done
