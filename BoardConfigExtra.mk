#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit MiuiCamera Makefile
-include vendor/xiaomi/miuicamera-$(PRODUCT_DEVICE)/BoardConfig.mk

# Inherit SELinux Makefile
include $(VENDOR_EXTRA_PATH)/sepolicy/SEPolicy.mk

# Kernel
ifneq (,$(filter $(PRODUCT_DEVICE),cerro dodge tiro xaga))
KERNEL_LTO := thin
endif

# Partitions - reserved size
ifeq ($(PRODUCT_USE_DYNAMIC_PARTITIONS), true)
ifneq ($(BOARD_ODMIMAGE_FILE_SYSTEM_TYPE), erofs)
BOARD_ODMIMAGE_PARTITION_RESERVED_SIZE := 30720000
endif
ifneq ($(BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE), erofs)
BOARD_VENDORIMAGE_PARTITION_RESERVED_SIZE := 30720000
endif
endif

# Security patch level
ifeq ($(PRODUCT_DEVICE),miatoll)
# Workaround for dirty flash: Freeze vendor & boot SPL
# to the latest release to avoid clean flashes.
# https://github.com/ItsVixano-releases/LineageOS_miatoll/releases/tag/20250415
BOOT_SECURITY_PATCH := 2025-04-05
VENDOR_SECURITY_PATCH := 2025-04-05
endif
