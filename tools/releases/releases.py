#!/usr/bin/python3
# Copyright (C) 2024 Giovanni Ricca
# SPDX-License-Identifier: Apache-2.0

import sys

sys.dont_write_bytecode = True

import argparse
import hashlib
import pathlib
from time import sleep

import github_py as github

# Argument parser setup
parser = argparse.ArgumentParser(
    description='Create a GitHub release and upload assets.'
)
parser.add_argument(
    '-r',
    '--release',
    action='store_true',
    default=False,
    help='Flag to mark as release build',
)
parser.add_argument(
    '-b',
    '--beta',
    action='store_true',
    default=False,
    help='Flag to mark as beta release',
)
parser.add_argument('device', help='Device codename (test)')
parser.add_argument('release_spl', help='SPL Version (YYYY-MM-DD)')
parser.add_argument('release_build_date', help='Build date (YYYYMMDD)')
args = parser.parse_args()

# Pre-checks
assets_dir = pathlib.Path('assets')
if not assets_dir.exists():
    print(
        f'\nError: The directory `{assets_dir}` does not exist.\n'
        'Please create a folder named `assets` with all the assets you want to upload inside it.'
    )
    sys.exit(1)

if not assets_dir.is_dir():
    print(
        f'\nError: `{assets_dir}` is not a directory.\n'
        'Please create a folder named `assets` with all the assets you want to upload inside it.'
    )
    sys.exit(1)

if not any(assets_dir.iterdir()):
    print(
        f'\nError: The directory `{assets_dir}` is empty.\n'
        'Please add the assets you want to upload inside the `assets` folder.'
    )
    sys.exit(1)


# defs
def get_device(var):
    return {
        # LineageOS 22.0
        'daisy': {1: 'Mi A2 Lite', 2: '22.0', 3: 'LineageOS_daisy'},
        'gemstone': {1: 'Redmi Note 12 5G', 2: '22.0', 3: 'LineageOS_gemstone'},
        'lisa': {1: 'Xiaomi 11 Lite 5G NE', 2: '22.0', 3: 'LineageOS_lisa'},
        'miatoll': {1: 'Xiaomi Atoll Family', 2: '22.0', 3: 'LineageOS_miatoll'},
        'sakura': {1: 'Redmi 6 Pro', 2: '22.0', 3: 'LineageOS_sakura'},
        'xaga': {1: 'POCO X4 GT', 2: '22.0', 3: 'LineageOS_xaga'},
        'ysl': {1: 'Redmi S2/Y2', 2: '22.0', 3: 'LineageOS_ysl'},
        # LineageOS 21.0
        # - None
        # LineageOS 20.0
        'prague': {1: 'Huawei P8 Lite 2017', 2: '20.0', 3: 'LineageOS_prague'},
        'stanford': {1: 'Honor 9', 2: '20.0', 3: 'LineageOS_stanford'},
        # Test
        'test': {1: 'Test Device', 2: '12.3', 3: 'LineageOS_test'},
        'test_priv': {1: 'Test Device', 2: '12.3', 3: 'LineageOS_test_priv'},
    }.get(var)  # fmt: skip


def sha1sum(var):
    file_hash = hashlib.sha1()
    BLOCK_SIZE = 67108864  # 64MB
    with open('assets/' + var, 'rb') as f:
        for chunk in iter(lambda: f.read(BLOCK_SIZE), b''):
            file_hash.update(chunk)

    return file_hash.hexdigest()


# Vars
GH_ASSETS = list(assets_dir.iterdir())
GH_OWNER = 'ItsVixano-releases'  # Github profile name
GH_REPO = get_device(args.device)[3]  # Github repo name
GH_SECPATCH = args.release_spl  # LineageOS Security patch level
GH_TAG = args.release_build_date  # Github release tag name
GH_LINEAGE = get_device(args.device)[2]  # LineageOS Release
GH_NAME = f"LineageOS {GH_LINEAGE} for {get_device(args.device)[1]} ({GH_TAG.replace('-', '')})"
GH_MESSAGE = f"""📅 Build date: `{GH_TAG}`

🔒 Security patches: `{GH_SECPATCH}`

📔 [Changelog](https://raw.githubusercontent.com/ItsVixano-releases/{GH_REPO}/main/lineage-{GH_LINEAGE[:-2]}/changelog_{GH_TAG.replace('-', '')}.txt)
📕 [Wiki & Instructions](https://wiki.itsvixano.me/devices/{args.device}/)
🔧 [Bug reporting](https://wiki.itsvixano.me/troubleshooting/)"""

# Calculate the sha1sums of the assets
GH_MESSAGE += '\n\n🔗 Sha1sums'
for asset in GH_ASSETS:
    print(f'\nCalculating sha1sum for `{asset.name}`')
    GH_MESSAGE += f'\n`{sha1sum(asset.name)} {asset.name}`'

# Create release
print('\nCreating a release page ...')
release_data = {
    'tag_name': GH_TAG.replace('-', ''),
    'name': GH_NAME,
    'body': GH_MESSAGE,
    'draft': not args.release,
    'prerelease': args.beta,
}
release = github.create_git_release(GH_OWNER, GH_REPO, release_data).json()
release_id = release['id']

# Upload assets
for asset in GH_ASSETS:
    print(f'\nUploading `{asset.name}`')
    github.upload_asset(GH_OWNER, GH_REPO, release_id, str(asset))

print(
    '\nDone! '
    f'You can find the uploaded assets on https://github.com/{GH_OWNER}/{GH_REPO}/releases'
)
