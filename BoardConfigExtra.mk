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
TARGET_PRODUCT_PROP += $(VENDOR_EXTRA_PATH)/props/product.prop
ifneq ($(filter msm8953 hi3660 hi6250,$(TARGET_BOARD_PLATFORM)),)
TARGET_PRODUCT_PROP += $(VENDOR_EXTRA_PATH)/props/go_product.prop
endif
