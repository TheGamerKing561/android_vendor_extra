#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

VENDOR_EXTRA_PATH := vendor/extra

VENDOR_EXTRA_TARGET_DEVICE := $(shell echo -n $(TARGET_PRODUCT) | sed -e 's/^[a-z]*_//g')

# Inherit vendor/extra configs
$(call inherit-product, $(VENDOR_EXTRA_PATH)/config/go.mk)
$(call inherit-product, $(VENDOR_EXTRA_PATH)/config/properties.mk)
$(call inherit-product, $(VENDOR_EXTRA_PATH)/config/security.mk)

# Inherit MiuiCamera Makefile
$(call inherit-product-if-exists, vendor/xiaomi/miuicamera-$(VENDOR_EXTRA_TARGET_DEVICE)/device.mk)

# Inherit Pixel clocks Makefile
$(call inherit-product, vendor/pixel_clocks/product.mk)

ifneq ($(filter dodge lisa nairo venus,$(VENDOR_EXTRA_TARGET_DEVICE)),)
# NFC
$(call soong_config_set,lineage_extra,product_has_nfc,true)
endif

ifeq ($(filter dodge,$(VENDOR_EXTRA_TARGET_DEVICE)),)
# Boot animation
TARGET_BOOTANIMATION_HALF_RES := true
endif

# Bellis
PRODUCT_PACKAGES += \
    Bellis

# Init
PRODUCT_PACKAGES += \
    init.extra.rc

# Iperf3
PRODUCT_PACKAGES += \
    iperf3

# Overlays
PRODUCT_PACKAGES += \
    FrameworkOverlayEXTRA \
    NfcOverlayEXTRA \
    SettingsOverlayEXTRA \
    SettingsProviderOverlayEXTRA \
    SimpleDeviceConfigOverlayEXTRA \
    SystemUIOverlayEXTRA \
    UpdaterOverlayEXTRA

# tinymix
PRODUCT_PACKAGES += \
    tinymix
