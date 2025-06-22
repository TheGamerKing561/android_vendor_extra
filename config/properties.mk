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

# Audio service timeout
PRODUCT_PRODUCT_PROPERTIES += \
    audio.service.client_wait_ms=10000

ifneq ($(filter dodge nairo,$(VENDOR_EXTRA_TARGET_DEVICE)),)
# OEM Unlock reporting
PRODUCT_PRODUCT_PROPERTIES += \
    ro.oem_unlock_supported=0
endif
