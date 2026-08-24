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
ifneq (,$(filter $(TARGET_BOARD_PLATFORM),lahaina))
BOOT_SECURITY_PATCH := $(VENDOR_SECURITY_PATCH)
endif
ifneq (,$(filter $(TARGET_BOARD_PLATFORM),mt6897 pineapple sun))
KERNEL_LTO := thin
endif

# Kernel (prebuilt)
ifeq ($(TARGET_FORCE_PREBUILT_KERNEL), true)
include kernel/lineage/prebuilts/BoardConfigKernel.mk
endif

# Kernel (serial)
#   modprobe cdc-acm
#   putty -serial /dev/ttyACM0 -sercfg 115200
#   or
#   while true; do test -e /dev/ttyACM0 && sleep 0.1 && cat /dev/ttyACM0 | grep -vE "^\s?\n$"; done
ifeq ($(WITH_USB_SERIAL), true)
BOARD_KERNEL_CMDLINE += console=ttyGS0
TARGET_KERNEL_CONFIG_EXT += $(VENDOR_EXTRA_PATH)/kernel/configs/usbserial.config
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
