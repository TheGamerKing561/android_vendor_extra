#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# ADB
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.adb.shell=/system_ext/bin/bash #\
    #service.adb.tcp.port=5555

# OEM Unlock reporting
PRODUCT_PRODUCT_PROPERTIES += \
    ro.oem_unlock_supported=0

# Log tag
PRODUCT_PRODUCT_PROPERTIES += \
    persist.log.tag.HWUI=S
