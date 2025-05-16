#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit MiuiCamera Makefile
-include vendor/xiaomi/miuicamera-$(PRODUCT_DEVICE)/BoardConfig.mk

# Inherit SELinux Makefile
include $(VENDOR_EXTRA_PATH)/sepolicy/SEPolicy.mk

# Soong namespace
ifeq ($(BOARD_USES_QCOM_HARDWARE),true)
ifneq ($(TARGET_BOARD_PLATFORM),sun)
PRODUCT_SOONG_NAMESPACES += \
    hardware/qcom-caf/thermal
endif #TARGET_BOARD_PLATFORM
endif #BOARD_USES_QCOM_HARDWARE
