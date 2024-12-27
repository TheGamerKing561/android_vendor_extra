#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

VENDOR_EXTRA_PUBLIC_KEYS_PATH := vendor/extra/build/target/product/security

# MindTheGapps
PRODUCT_EXTRA_RECOVERY_KEYS += \
    $(VENDOR_EXTRA_PUBLIC_KEYS_PATH)/mindthegapps

# Spoof `dev-keys` builds into `release-keys`
ifneq ($(DEFAULT_SYSTEM_DEV_CERTIFICATE),build/make/target/product/security/testkey)
PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildVersionTags="release-keys" \
    LineageDesc="$(BUILD_ID)"
endif
