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

# Graphics
TARGET_GAME_DEFAULT_FRAME_RATE ?= 60
ifneq ($(filter lisa nairo racer,$(VENDOR_EXTRA_TARGET_DEVICE)),)
TARGET_GAME_DEFAULT_FRAME_RATE := 90
endif
ifneq ($(filter cerro gemstone tiro venus,$(VENDOR_EXTRA_TARGET_DEVICE)),)
TARGET_GAME_DEFAULT_FRAME_RATE := 120
endif
ifneq ($(filter xaga,$(VENDOR_EXTRA_TARGET_DEVICE)),)
TARGET_GAME_DEFAULT_FRAME_RATE := 144
endif

PRODUCT_PRODUCT_PROPERTIES += \
    ro.surface_flinger.game_default_frame_rate_override=$(TARGET_GAME_DEFAULT_FRAME_RATE)

ifneq ($(filter xaga,$(VENDOR_EXTRA_TARGET_DEVICE)),)
# Display
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.activity_anim_perf_override=true
endif
