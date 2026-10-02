#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# ADB
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.adb.shell=/system_ext/bin/bash #\
    #service.adb.tcp.port=5555

# Disable default frame rate limit for games
PRODUCT_PRODUCT_PROPERTIES += \
    debug.graphics.game_default_frame_rate.disabled=true

# OEM Unlock reporting
PRODUCT_PRODUCT_PROPERTIES += \
    ro.oem_unlock_supported=0

# SurfaceFlinger
TARGET_GAME_DEFAULT_FRAME_RATE ?= 60

PRODUCT_PRODUCT_PROPERTIES += \
    ro.surface_flinger.game_default_frame_rate_override=$(TARGET_GAME_DEFAULT_FRAME_RATE) \
    debug.sf.enable_egl_image_tracker=0

# Enable Material Design 3 Expressive
PRODUCT_PRODUCT_PROPERTIES += \
    is_expressive_design_enabled=true

# hwui
PRODUCT_PRODUCT_PROPERTIES += \
    debug.hwui.skia_tracing_enabled=false \
    debug.hwui.skia_use_perfetto_track_events=false
