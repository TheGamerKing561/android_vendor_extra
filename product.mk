#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

VENDOR_EXTRA_PATH := vendor/extra

VENDOR_EXTRA_TARGET_DEVICE := $(shell echo -n $(TARGET_PRODUCT) | sed -e 's/^[a-z]*_//g')

# Inherit vendor/extra configs
$(call inherit-product, $(VENDOR_EXTRA_PATH)/config/go.mk)
$(call inherit-product, $(VENDOR_EXTRA_PATH)/config/properties.mk)
$(call inherit-product, $(VENDOR_EXTRA_PATH)/config/security.mk)

# Inherit priv Makefile
$(call inherit-product-if-exists, $(VENDOR_EXTRA_PATH)/priv/product.mk)

# Inherit MiuiCamera Makefile
$(call inherit-product-if-exists, vendor/xiaomi/miuicamera-$(VENDOR_EXTRA_TARGET_DEVICE)/device.mk)

# Updater
$(call soong_config_set,lineage_extra,product_version_major,$(PRODUCT_VERSION_MAJOR))

# Audio (Debugging)
PRODUCT_PACKAGES += \
    tinymix \
    tinyplay

# Boot animation
TARGET_BOOTANIMATION_HALF_RES := true

# Bellis
PRODUCT_PACKAGES += \
    Bellis

# Overlays
PRODUCT_PACKAGES += \
    FrameworksResCustomOverlay \
    LineageUpdaterOverlay \
    RippleSystemUIOverlay \
    SimpleDeviceConfigOverlay \
    SystemUICustomOverlay

# Rootdir
PRODUCT_PACKAGES += \
    init.safailnet.rc

PRODUCT_PACKAGES += \
    neofetch

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(VENDOR_EXTRA_PATH)
