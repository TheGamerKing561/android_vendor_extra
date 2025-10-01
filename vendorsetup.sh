# Shebang is intentionally missing - do not run as a script

# SPDX-FileCopyrightText: Giovanni Ricca
# SPDX-License-Identifier: Apache-2.0

# Hardcode High Memory Parallel Process
export NINJA_HIGHMEM_NUM_JOBS=1

# Override host metadata to make builds more reproducible and avoid leaking info
export BUILD_USERNAME=android-build
export BUILD_HOSTNAME=$(openssl rand -hex 6)

# Make smaller .tar.gz files by excluding debug targets.
export ART_BUILD_TARGET_DEBUG=false
export ART_BUILD_HOST_DEBUG=false
export USE_DEX2OAT_DEBUG=false

# Defs
LOS_VERSION=$(sed -n 's/PRODUCT_VERSION_MAJOR = //p' $(gettop)/vendor/lineage/config/version.mk)
AOSP_TARGET_RELEASE=$(sed -n 's/aosp_target_release=//p' $(gettop)/vendor/lineage/vars/aosp_target_release)
VENDOR_EXTRA_PATH=$(gettop)/vendor/extra
MKA_JOBS=$(($(nproc) - 5))
[[ $(cat /etc/hostname) = "asus" ]] && MKA_JOBS=8
[[ $(cat /etc/hostname) = "cringemachine" ]] && MKA_JOBS=15

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

    local root_dir=$(gettop)

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
    apply_patches "${VENDOR_EXTRA_PATH}"/build/patches/lineage-"${LOS_VERSION}"
    gen_release_config_map
fi

# Call _TOP/infra/vendorsetup.sh
echo "including infra/vendorsetup.sh"
. $(gettop)/infra/vendorsetup.sh

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

function mka_kernel() {
    # Defs
    DEVICE=""
    BETA_BUILD="false"
    local BUILD_TYPE="userdebug"

    while [ "$#" -gt 0 ]; do
        case "${1}" in
            --device)
                DEVICE="${2}"
                ;;
        esac
        shift
    done

    if [[ -z "${DEVICE}" ]]; then
        LOGE "Please define --device value"
        return 0
    fi

    # Build
    breakfast "${DEVICE}" "${BUILD_TYPE}"

    declare -A device_kernel_targets=(
        [gemstone]="dtboimage vendorbootimage"
        [lisa]="dtboimage vendor_dlkmimage vendorbootimage"
        [miatoll]="dtboimage"
        [nairo]="dtboimage vendorimage"
        [racer]="dtboimage vendorimage"
        [venus]="dtboimage vendor_dlkmimage vendorbootimage"
        [xaga]="vendor_dlkmimage vendorbootimage"
    )

    kernel_targets="bootimage ${device_kernel_targets[$DEVICE]}"

    while ! mka ${kernel_targets} -j${MKA_JOBS}; do
        LOGE "${kernel_targets} failed!"
        return 0
    done

    LOGI "Done!"
}
