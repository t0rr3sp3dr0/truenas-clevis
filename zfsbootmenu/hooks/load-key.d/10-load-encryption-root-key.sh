#!/bin/sh
set -e

exec zfs load-key -L 'prompt' "${ZBM_ENCRYPTION_ROOT}" <<< 'nimda_saneurt'
