#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Dexpreopt
WITH_DEXPREOPT_DEBUG_INFO := false

# Disable debugging in userdebug builds
PRODUCT_NOT_DEBUGGABLE_IN_USERDEBUG := true

# Enable whole-program R8 Java optimizations for SystemUI and system_server,
SYSTEM_OPTIMIZE_JAVA := true
SYSTEMUI_OPTIMIZE_JAVA := true

# Do not build non-GSI partition images.
PRODUCT_BUILD_DEBUG_BOOT_IMAGE := false
PRODUCT_BUILD_DEBUG_VENDOR_BOOT_IMAGE := false
