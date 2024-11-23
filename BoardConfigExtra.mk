#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit priv Makefile
-include $(VENDOR_EXTRA_PATH)/priv/BoardConfigPriv.mk

# Inherit MiuiCamera Makefile
-include vendor/xiaomi/miuicamera-$(PRODUCT_DEVICE)/BoardConfig.mk

# Props
TARGET_VENDOR_PROP += $(VENDOR_EXTRA_PATH)/props/vendor.prop
TARGET_SYSTEM_EXT_PROP += $(VENDOR_EXTRA_PATH)/props/system_ext.prop
ifneq ($(filter msm8953 hi3660 hi6250,$(TARGET_BOARD_PLATFORM)),)
TARGET_VENDOR_PROP += $(VENDOR_EXTRA_PATH)/props/go_vendor.prop
TARGET_SYSTEM_EXT_PROP += $(VENDOR_EXTRA_PATH)/props/go_system_ext.prop
endif
