# Shebang is intentionally missing - do not run as a script

# SPDX-FileCopyrightText: Giovanni Ricca
# SPDX-License-Identifier: Apache-2.0

# Override host metadata to make builds more reproducible and avoid leaking info
export BUILD_USERNAME=android-user
export BUILD_HOSTNAME=r-0123456789abcdef-0123

# Make smaller .tar.gz files by excluding debug targets.
export ART_BUILD_TARGET_NDEBUG=true
export ART_BUILD_TARGET_DEBUG=false
export ART_BUILD_HOST_NDEBUG=true
export ART_BUILD_HOST_DEBUG=false
export USE_DEX2OAT_DEBUG=false

# Hardcode High Memory Parallel Process
export NINJA_HIGHMEM_NUM_JOBS=1

# Defs
LOS_VERSION=$(sed -n 's/PRODUCT_VERSION_MAJOR = //p' $(gettop)/vendor/lineage/config/version.mk)
AOSP_TARGET_RELEASE=$(sed -n 's/aosp_target_release=//p' $(gettop)/vendor/lineage/vars/aosp_target_release)
VENDOR_EXTRA_PATH=$(gettop)/vendor/extra
MKA_JOBS=$(($(nproc) - 5))
[[ $(cat /etc/hostname) = "asus" ]] && MKA_JOBS=10
[[ $(cat /etc/hostname) = "cringemachine" ]] && MKA_JOBS=15

# Logging defs
LOGI() {
    echo -e "\n\033[32m[INFO]: $1\033[0m"
}

LOGW() {
    echo -e "\n\033[33m[WARNING]: $1\033[0m"
}

LOGE() {
    echo -e "\n\033[31m[ERROR]: $1\033[0m"
}

# Apply patches
apply_patches() {
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
gen_release_config_map() {
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
fi
gen_release_config_map

# functions
los_changelog() {
    # Defs
    local datetime_utc=$(cat out/target/product/"${DEVICE}"/system/build.prop | grep ro.build.date.utc=)
    local datetime=$(date -d @${datetime_utc#*=} +%Y%m%d)
    local changelog_path="${VENDOR_EXTRA_PATH}"/tools/releases/LineageOS_"${DEVICE}"/lineage-"${LOS_VERSION}"
    local changelog=${changelog_path}/changelog_${datetime}.txt

    if [[ -z "${DEVICE}" ]]; then
        LOGE "Please define \${DEVICE} value"
        return 0
    fi

    # Delete the changelog if it already exists
    mkdir -p ${changelog_path}
    rm -rf ${changelog}

    # Thanks to @ ArianK16a
    # Generate changelog for 7 days
    for i in $(seq 7); do
        after_date=$(date --date="$i days ago" +%F)
        until_date=$(date --date="$(expr ${i} - 1) days ago" +%F)
        echo "====================" >>${changelog}
        echo "     $until_date    " >>${changelog}
        echo "====================" >>${changelog}
        while read path; do
            git_log=$(git --git-dir ./${path}/.git log --after=$after_date --until=$until_date --format=tformat:"%h %s [%an]")
            if [[ ! -z "${git_log}" ]]; then
                echo "* ${path}" >>${changelog}
                echo "${git_log}" >>${changelog}
                echo "" >>${changelog}
            fi
        done <./.repo/project.list
    done
}

upload_assets() {
    # Defs
    local datetime_utc=$(cat out/target/product/"${DEVICE}"/system/build.prop | grep ro.build.date.utc=)
    local datetime=$(date -d @${datetime_utc#*=} +%Y-%m-%d)
    local secpatch_prop=$(cat out/target/product/"${DEVICE}"/system/build.prop | grep ro.build.version.security_patch=)
    local secpatch=${secpatch_prop#ro.build.version.security_patch=}
    files=(
        # LineageOS Recovery zip
        "lineage-*.zip"
        # Lineage Recovery
        "boot.img"
        "dtbo.img"
        "recovery.img"
        "recovery_vendor.img"
        "vendor_boot.img"
        # Extras
        "super_empty.img"
        "vbmeta.img"
        "vendor_dlkm.img"
    )

    if [[ -z "${DEVICE}" ]]; then
        LOGE "Please define \${DEVICE} value"
        return 0
    fi

    # Upload assets on github
    mkdir -p "${VENDOR_EXTRA_PATH}"/tools/releases/assets
    rm -rf "${VENDOR_EXTRA_PATH}"/tools/releases/assets/*
    cd out/target/product/"${DEVICE}"/ &>/dev/null
    for file in "${files[@]}"; do
        cp ${file} "${VENDOR_EXTRA_PATH}"/tools/releases/assets &>/dev/null
    done
    cd "${VENDOR_EXTRA_PATH}"/tools/releases/

    if [[ "${RELEASE_BUILD}" == "true" ]]; then
        [[ "${BETA_BUILD}" == "true" ]] && ./releases.py "${DEVICE}" -r -b ${secpatch} ${datetime}
        [[ "${BETA_BUILD}" == "false" ]] && ./releases.py "${DEVICE}" -r ${secpatch} ${datetime}
    else
        ./releases.py "${DEVICE}" ${secpatch} ${datetime}
    fi

    # Return to the root dir
    croot

    if [[ "${RELEASE_BUILD}" == "true" ]]; then
        # Generate changelog
        los_changelog

        # Generate the OTA Json
        cd out/target/product/"${DEVICE}"/ &>/dev/null
        "${VENDOR_EXTRA_PATH}"/tools/releases/los_ota_json.py -r

        # Return to the root dir
        croot
    fi
}

manual_upload_assets() {
    # Defs
    DEVICE=""
    RELEASE_BUILD="false"
    BETA_BUILD="false"

    while [ "$#" -gt 0 ]; do
        case "${1}" in
            --device)
                DEVICE="${2}"
                ;;
            -r | --release-build)
                RELEASE_BUILD="true"
                ;;
            -b | --beta)
                BETA_BUILD="true"
                ;;
        esac
        shift
    done

    if [[ -z "${DEVICE}" ]]; then
        LOGE "Please define --device value"
        return 0
    fi

    [[ "${RELEASE_BUILD}" == "true" ]] && LOGW "Pushing the build to the public once is done"
    [[ "${BETA_BUILD}" == "true" ]] && LOGW "Pushing the build as a beta once is done"

    LOGI "Uploading the builds to the internet :D"
    upload_assets
}

mka_build() {
    # Defs
    DEVICE=""
    RELEASE_BUILD="false"
    BETA_BUILD="false"
    local DIRTY_BUILD="false"
    local BUILD_TYPE="userdebug"
    local LOCAL_BUILD=$([ "$(cat /etc/hostname)" = "asus" ] && echo "true" || echo "false")
    export WITH_GMS=
    export TARGET_UNOFFICIAL_BUILD_ID=

    while [ "$#" -gt 0 ]; do
        case "${1}" in
            --device)
                DEVICE="${2}"
                ;;
            -r | --release-build)
                RELEASE_BUILD="true"
                ;;
            -b | --beta)
                BETA_BUILD="true"
                ;;
            -d | --dirty)
                local DIRTY_BUILD="true"
                ;;
            --build-type)
                local BUILD_TYPE="${2}"
                ;;
            -l | --local-build)
                local LOCAL_BUILD="true"
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

    [[ "${RELEASE_BUILD}" == "true" ]] && LOGW "Pushing the build to the public once is done"
    [[ "${BETA_BUILD}" == "true" ]] && LOGW "Pushing the build as a beta once is done"

    # Build
    rm -rf out/target/product/"${DEVICE}"/lineage-*.zip &>/dev/null
    find out/target/product/"${DEVICE}" -name manifest.xml -delete &>/dev/null
    breakfast "${DEVICE}" "${BUILD_TYPE}"

    [[ "${DIRTY_BUILD}" != "true" ]] && mka installclean

    while ! mka bacon -j${MKA_JOBS}; do
        LOGE "bacon failed!"
        return 0
    done

    if [[ "${LOCAL_BUILD}" != "true" ]] || [[ "${RELEASE_BUILD}" == "true" ]]; then
        LOGI "Uploading the builds to the internet :D"
        upload_assets
    fi

    LOGI "Done!"
}

mka_kernel() {
    # Defs
    DEVICE=""
    RELEASE_BUILD="false"
    BETA_BUILD="false"
    local BUILD_TYPE="userdebug"
    local LOCAL_BUILD=$([ "$(cat /etc/hostname)" = "asus" ] && echo "true" || echo "false")

    while [ "$#" -gt 0 ]; do
        case "${1}" in
            --device)
                DEVICE="${2}"
                ;;
            -l | --local-build)
                local LOCAL_BUILD="true"
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
    mka installclean

    declare -A device_kernel_targets
    device_kernel_targets["dodge"]="bootimage dtboimage vendorbootimage vendor_dlkmimage system_dlkmimage initbootimage"
    device_kernel_targets["gemstone"]="bootimage dtboimage vendorbootimage"
    device_kernel_targets["lisa"]="bootimage dtboimage vendorbootimage vendor_dlkmimage"
    device_kernel_targets["miatoll"]="bootimage dtboimage"
    device_kernel_targets["xaga"]="bootimage vendorbootimage vendor_dlkmimage"

    kernel_targets=${device_kernel_targets[$DEVICE]:-"bootimage"}

    while ! mka ${kernel_targets} -j${MKA_JOBS}; do
        LOGE "${kernel_targets} failed!"
        return 0
    done

    if [[ "${LOCAL_BUILD}" != "true" ]]; then
        LOGI "Uploading the builds to the internet :D"
        upload_assets
    fi

    LOGI "Done!"
}
