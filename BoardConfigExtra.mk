#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit MiuiCamera Makefile
-include vendor/xiaomi/miuicamera-$(PRODUCT_DEVICE)/BoardConfig.mk

# Inherit extra Makefile
include $(VENDOR_EXTRA_PATH)/sepolicy/SEPolicy.mk

# Architecture
ifneq (,$(filter $(TARGET_BOARD_PLATFORM),lahaina))
TARGET_ARCH_VARIANT := armv8-2a-dotprod
endif

# Kernel
ifneq (,$(filter $(TARGET_BOARD_PLATFORM),mt6895 pineapple sun))
KERNEL_LTO := thin
endif

# Partitions (treble) - reserved size
EXTRA_TREBLE_PARTITIONS := odm vendor
EXTRA_TREBLE_RESERVE_SIZE := 104857600 # 100mb * 1024 * 1024
ifeq ($(PRODUCT_USE_DYNAMIC_PARTITIONS), true)
$(foreach p, $(call to-upper, $(EXTRA_TREBLE_PARTITIONS)), \
    $(if $(filter-out erofs, $(BOARD_$(p)IMAGE_FILE_SYSTEM_TYPE)), \
        $(if $(BOARD_$(p)IMAGE_PARTITION_RESERVED_SIZE),, \
            $(eval BOARD_$(p)IMAGE_PARTITION_RESERVED_SIZE := $(EXTRA_TREBLE_RESERVE_SIZE)))))
endif

# Security patch level
ifeq ($(PRODUCT_DEVICE),miatoll)
# Workaround for dirty flash: Freeze vendor & boot SPL
# to the latest release to avoid clean flashes.
# https://github.com/ItsVixano-releases/LineageOS_miatoll/releases/tag/20250415
BOOT_SECURITY_PATCH := 2025-04-05
VENDOR_SECURITY_PATCH := 2025-04-05
endif
