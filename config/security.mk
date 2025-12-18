#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

VENDOR_EXTRA_PUBLIC_KEYS_PATH := vendor/extra/build/target/product/security

# MindTheGapps
# https://github.com/MindTheGapps
PRODUCT_EXTRA_RECOVERY_KEYS += \
    $(VENDOR_EXTRA_PUBLIC_KEYS_PATH)/mindthegapps

# microG Installer
# https://t.me/microG_installer_ci
PRODUCT_EXTRA_RECOVERY_KEYS += \
    $(VENDOR_EXTRA_PUBLIC_KEYS_PATH)/microginstaller
