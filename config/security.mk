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

ifneq ($(DEFAULT_SYSTEM_DEV_CERTIFICATE),build/make/target/product/security/testkey)
PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildFlavor="$(VENDOR_EXTRA_TARGET_DEVICE)-$(TARGET_BUILD_VARIANT)" \
    LineageDesc="$(BUILD_ID)"
endif
