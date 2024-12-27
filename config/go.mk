#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Speed profile services and wifi-service to reduce RAM and storage.
PRODUCT_SYSTEM_SERVER_COMPILER_FILTER := speed-profile

# Enable whole-program R8 Java optimizations for system_server,
FULL_SYSTEM_OPTIMIZE_JAVA := true

# Reduce system server verbosity
PRODUCT_SYSTEM_SERVER_DEBUG_INFO := false
PRODUCT_OTHER_JAVA_DEBUG_INFO := false

# Use the low memory allocator to save RSS.
MALLOC_LOW_MEMORY := true
