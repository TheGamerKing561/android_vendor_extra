#!/usr/bin/python3
# SPDX-FileCopyrightText: Giovanni Ricca
# SPDX-License-Identifier: Apache-2.0

import sys

sys.dont_write_bytecode = True

import argparse
import pathlib
import subprocess
from datetime import datetime as dt
from glob import glob
from re import search

from config import GH_TOKEN

# Argument parser setup
parser = argparse.ArgumentParser(
    description='Generate OTA JSON for LineageOS builds.'
)
parser.add_argument(
    '-r',
    '--release',
    action='store_true',
    default=False,
    help='Flag to mark as release build',
)
args = parser.parse_args()


def getprop(prop):
    return search(
        r''.join(['(?<=', prop, '=).*']),
        pathlib.Path('system/build.prop').read_text(),
    ).group(0)


version, datetime, incremental, codename = (
    getprop('ro.lineage.build.version'),  # version
    getprop('ro.build.date.utc'),  # datetime
    getprop('ro.build.version.incremental'),  # incremental
    getprop('ro.lineage.device'),  # codename
)

incremental_json = dt.fromtimestamp(int(incremental)).strftime('%Y%m%d')

filename = max(
    glob(''.join(['lineage-', version, '*', '.zip'])),
    key=lambda f: pathlib.Path(f).stat().st_ctime,
)
id = open(filename + '.sha256sum').read().split()[0]
size = pathlib.Path(filename).stat().st_size
url = ''.join(
    [
        'https://github.com/ItsVixano-releases/LineageOS_',
        codename,
        '/releases/download/',
        incremental_json,
        '/',
        filename,
    ]
)

# Write the ota json to every file present
ota_path = pathlib.Path(
    f'../../../../vendor/extra/tools/releases/LineageOS_{codename}/lineage-{version[:-2]}/'
)
ota = f"""{{
  "response": [
    {{
      "datetime": {datetime},
      "filename": "{filename}",
      "id": "{id}",
      "romtype": "unofficial",
      "size": {size},
      "url": "{url}",
      "version": "{version}"
    }}
  ]
}}
"""

for ota_json_file in ota_path.glob('*.json'):
    ota_json_file.write_text(ota)

# Write a dummy ota
dummy_ota = """{
  "response": []
}
"""
dummy_ota_json = ota_path / f'{incremental}.json'
dummy_ota_json.write_text(dummy_ota)

# Commit everything
subprocess.run(['git', 'add', '.'], cwd=ota_path)
subprocess.run(
    [
        'git',
        'commit',
        '-m',
        f'LineageOS_{codename}: lineage-{version[:-2]}: {incremental_json}',
        '--no-gpg-sign',
    ],
    cwd=ota_path,
)

if args.release:
    subprocess.run(
        [
            'git',
            'push',
            f'https://{GH_TOKEN}@github.com/ItsVixano-releases/LineageOS_{codename}.git',
            'HEAD:main',
        ],
        cwd=ota_path,
    )
