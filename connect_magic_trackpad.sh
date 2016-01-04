#!/bin/bash

MACADDR=88:63:DF:F0:E6:77
THIS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

sudo hidd --connect ${MACADDR}
bash ${THIS_DIR}/configure_magic_trackpad.sh
