#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit MiuiCamera Makefile
-include vendor/xiaomi/miuicamera-$(PRODUCT_DEVICE)/BoardConfig.mk

# SELinux
include $(VENDOR_EXTRA_PATH)/sepolicy/SEPolicy.mk
