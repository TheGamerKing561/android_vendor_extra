#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

VENDOR_EXTRA_PATH := vendor/extra

VENDOR_EXTRA_TARGET_DEVICE := $(shell echo -n $(TARGET_PRODUCT) | sed -e 's/^[a-z]*_//g')

# Inherit vendor/extra configs
$(call inherit-product, $(VENDOR_EXTRA_PATH)/config/properties.mk)
$(call inherit-product, $(VENDOR_EXTRA_PATH)/config/security.mk)

# Inherit Pixel clocks Makefile
$(call inherit-product, vendor/pixel_clocks/product.mk)

# Boot animation
TARGET_BOOTANIMATION_HALF_RES := true

# Iperf3
PRODUCT_PACKAGES += \
    iperf3

# Overlays
PRODUCT_PACKAGES += \
    FrameworkOverlayEXTRA \
    SettingsOverlayEXTRA \
    SettingsProviderOverlayEXTRA \
    SimpleDeviceConfigOverlayEXTRA \
    SystemUIOverlayEXTRA \
    UpdaterOverlayEXTRA

# tinymix
PRODUCT_PACKAGES += \
    tinymix
