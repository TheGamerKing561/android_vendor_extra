#
# Copyright (C) 2024-2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Speed profile services and wifi-service to reduce RAM and storage.
PRODUCT_SYSTEM_SERVER_COMPILER_FILTER := speed-profile

# Enable whole-program R8 Java optimizations for SystemUI and system_server,
SYSTEM_OPTIMIZE_JAVA := true
SYSTEMUI_OPTIMIZE_JAVA := true

# Reduce system server verbosity
PRODUCT_SYSTEM_SERVER_DEBUG_INFO := false
PRODUCT_OTHER_JAVA_DEBUG_INFO := false
PRODUCT_NOT_DEBUGGABLE_IN_USERDEBUG := true

# Dexpreopt
WITH_DEXPREOPT_DEBUG_INFO := false

# Use the low memory allocator to save RSS.
MALLOC_LOW_MEMORY := true

# Do not build non-GSI partition images.
PRODUCT_BUILD_DEBUG_BOOT_IMAGE := false
PRODUCT_BUILD_DEBUG_VENDOR_BOOT_IMAGE := false
