#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit MiuiCamera Makefile
-include vendor/xiaomi/miuicamera-$(PRODUCT_DEVICE)/BoardConfig.mk

# Inherit SELinux Makefile
include $(VENDOR_EXTRA_PATH)/sepolicy/SEPolicy.mk

# Kernel
ifneq (,$(filter $(PRODUCT_DEVICE),dodge))
BOARD_KERNEL_CMDLINE += \
    rcutree.enable_rcu_lazy=1
endif

ifneq (,$(filter $(PRODUCT_DEVICE),xaga dodge))
KERNEL_LTO := thin
endif

# Security patch level
BOOT_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)
VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)
