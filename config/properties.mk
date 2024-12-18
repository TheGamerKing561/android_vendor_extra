#
# properties for extra
#

# ADB
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.adb.shell=/system_ext/bin/bash #\
    #service.adb.tcp.port=5555

# Use 64-bit dex2oat for better dexopt time.
PRODUCT_PRODUCT_PROPERTIES += \
    dalvik.vm.dex2oat64.enabled=true

# Too many tombstones can cause bugreports to grow too large to be uploaded.
PRODUCT_PRODUCT_PROPERTIES += \
    tombstoned.max_tombstone_count=10

# Lineage Updater
PRODUCT_PRODUCT_PROPERTIES += \
    lineage.updater.allow_major_update=true

ifneq ($(filter daisy prague stanford ysl,$(VENDOR_EXTRA_TARGET_DEVICE)),)
# Set lowram options
PRODUCT_PRODUCT_PROPERTIES += \
    ro.lmk.critical_upgrade=true \
    ro.lmk.upgrade_pressure=40 \
    ro.lmk.downgrade_pressure=60 \
    ro.lmk.kill_heaviest_task=false

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
