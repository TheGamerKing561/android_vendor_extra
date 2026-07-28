# Shebang is intentionally missing - do not run as a script

# SPDX-FileCopyrightText: Giovanni Ricca
# SPDX-License-Identifier: Apache-2.0

# Hardcode High Memory Parallel Process
export NINJA_HIGHMEM_NUM_JOBS=3

# Override host metadata to make builds more reproducible and avoid leaking info
# Commented out for now
#export BUILD_USERNAME=android-build
#export BUILD_HOSTNAME=$(openssl rand -hex 6)

# Dexpreopt
export WITH_DEXPREOPT_DEBUG_INFO=false

# Enable whole-program R8 Java optimizations for SystemUI and system_server,
export SYSTEM_OPTIMIZE_JAVA=true
export SYSTEMUI_OPTIMIZE_JAVA=true

# Make smaller .tar.gz files by excluding debug targets.
export ART_BUILD_TARGET_DEBUG=false
export ART_BUILD_HOST_DEBUG=false
export USE_DEX2OAT_DEBUG=false

# ABI compatibility checks fail for several reasons:
#   - The update to Clang 12 causes some changes, but no breakage has been
#     observed in practice.
#   - Switching to zlib-ng changes some internal structs, but not the public
#     API.
#
# We may fix these eventually by updating the ABI specifications, but it's
# likely not worth the effort for us because of how many repos are affected.
# We would need to fork a lot of extra repos (thus increasing maintenance
# overhead) just to update the ABI specs.
#
# For now, just skip the ABI checks to fix build errors.
export SKIP_ABI_CHECKS=true

# HAX
export LINEAGE_FIXUP_COMMON_OUT=true
export TOP=$(gettop)

# Defs
ANDROID_VERSION=$(sed -n 's/PRODUCT_VERSION_MAJOR = //p' ${TOP}/vendor/lineage/config/version.mk)
AOSP_TARGET_RELEASE=$(sed -n 's/aosp_target_release=//p' ${TOP}/vendor/lineage/vars/aosp_target_release)
VENDOR_EXTRA_PATH=${TOP}/vendor/extra

# Logging defs
function LOGI() {
    echo -e "\n\033[32m[INFO]: $1\033[0m"
}

function LOGW() {
    echo -e "\n\033[33m[WARNING]: $1\033[0m"
}

function LOGE() {
    echo -e "\n\033[31m[ERROR]: $1\033[0m"
}

# Apply patches
function apply_patches() {
    local patches_dir="$1"

    [[ ! -d "${patches_dir}" ]] && return

    local root_dir=${TOP}

    for project_name in "${patches_dir}"/*/; do
        # Remove trailing slash
        project_name=${project_name%/}
        # Get the base name
        project_name=${project_name##*/}

        # Handle special cases
        local project_path=$(tr _ / <<<"${project_name}")

        [[ "${project_name}" == "external_jemalloc_new" ]] && project_path="external/jemalloc_new"

        cd "${root_dir}/${project_path}" || continue

        # Apply patches and suppress abort messages
        LOGI "Applying patches from ${patches_dir}/${project_name}\n"
        git am --no-gpg-sign "${patches_dir}/${project_name}"/*.patch || git am --abort &>/dev/null
    done

    # Return to source root directory
    croot
}

# Generate "release_config_map.textproto"
function gen_release_config_map() {
    cat <<EOF > "${VENDOR_EXTRA_PATH}/release/release_config_map.textproto"
default_containers: "product"
default_containers: "system"
default_containers: "system_ext"
default_containers: "vendor"

release_config {
    name: "${AOSP_TARGET_RELEASE}"
    flag_value_files: "release_configs/${AOSP_TARGET_RELEASE}.textproto"
}

build_config {
    name: "${AOSP_TARGET_RELEASE}"
    flag_value_files: "build_config/${AOSP_TARGET_RELEASE}.textproto"
}
EOF
}

if [[ "${APPLY_PATCHES}" == "true" ]]; then
    apply_patches "${VENDOR_EXTRA_PATH}"/build/patches/evolution-a"${ANDROID_VERSION}"
    gen_release_config_map
fi

# functions
function mka_build() {
    # Defs
    DEVICE=""
    local DIRTY_BUILD="false"
    local BUILD_TYPE="userdebug"
    export WITH_GMS=
    export TARGET_UNOFFICIAL_BUILD_ID=

    while [ "$#" -gt 0 ]; do
        case "${1}" in
            --device)
                DEVICE="${2}"
                ;;
            -d | --dirty)
                local DIRTY_BUILD="true"
                ;;
            --build-type)
                local BUILD_TYPE="${2}"
                ;;
            --microg)
                export WITH_GMS=true
                export TARGET_UNOFFICIAL_BUILD_ID=microG
                ;;
        esac
        shift
    done

    if [[ -z "${DEVICE}" ]]; then
        LOGE "Please define --device value"
        return 0
    fi

    # Build
    rm -rf out/target/product/"${DEVICE}"/lineage-*.zip &>/dev/null
    rm -rf out/soong/.intermediates/vendor/lineage/build/soong/generated_kernel_includes &>/dev/null
    find out/target/product/"${DEVICE}" -name manifest.xml -delete &>/dev/null
    breakfast "${DEVICE}" "${BUILD_TYPE}"

    [[ "${DIRTY_BUILD}" != "true" ]] && mka installclean

    while ! mka bacon -j${MKA_JOBS}; do
        LOGE "bacon failed!"
        return 0
    done

    LOGI "Done!"
}
