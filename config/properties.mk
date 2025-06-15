#
# properties for extra
#

# ADB
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.adb.shell=/system_ext/bin/bash #\
    #service.adb.tcp.port=5555

# Too many tombstones can cause bugreports to grow too large to be uploaded.
PRODUCT_PRODUCT_PROPERTIES += \
    tombstoned.max_tombstone_count=10

# Audio service timeout
PRODUCT_PRODUCT_PROPERTIES += \
    audio.service.client_wait_ms=10000

ifneq ($(filter stanford,$(VENDOR_EXTRA_TARGET_DEVICE)),)
# set threshold to filter unused apps
PRODUCT_PRODUCT_PROPERTIES += \
    pm.dexopt.downgrade_after_inactive_days=10

# set the compiler filter for shared apks to verify.
PRODUCT_PRODUCT_PROPERTIES += \
    pm.dexopt.shared=verify

# Memory optimizations
PRODUCT_PRODUCT_PROPERTIES += \
    ro.config.avoid_gfx_accel=true
endif

ifneq ($(filter dodge nairo,$(VENDOR_EXTRA_TARGET_DEVICE)),)
# OEM Unlock reporting
PRODUCT_PRODUCT_PROPERTIES += \
    ro.oem_unlock_supported=0
endif
