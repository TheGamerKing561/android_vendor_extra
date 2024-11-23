#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

VENDOR_EXTRA_PATH := vendor/extra

# Inherit vendor/extra configs
$(call inherit-product, vendor/extra/config/go.mk)
$(call inherit-product, vendor/extra/config/security.mk)

# Inherit priv Makefile
$(call inherit-product-if-exists, vendor/extra/priv/product.mk)

# Inherit MiuiCamera Makefile
$(call inherit-product-if-exists, vendor/xiaomi/miuicamera-$(shell echo -n $(TARGET_PRODUCT) | sed -e 's/^[a-z]*_//g')/device.mk)

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
    FrameworksResOverlay \
    LineageUpdaterOverlay \
    RippleSystemUIOverlay \
    SimpleDeviceConfigOverlay

# Rootdir
PRODUCT_COPY_FILES += \
    $(VENDOR_EXTRA_PATH)/rootdir/etc/init.safailnet.rc:$(TARGET_COPY_OUT_PRODUCT)/etc/init/init.safailnet.rc

PRODUCT_COPY_FILES += \
    $(VENDOR_EXTRA_PATH)/rootdir/bin/neofetch:$(TARGET_COPY_OUT_SYSTEM)/bin/neofetch

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(VENDOR_EXTRA_PATH)
