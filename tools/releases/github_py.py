#!/usr/bin/python3
# SPDX-FileCopyrightText: Giovanni Ricca
# SPDX-License-Identifier: Apache-2.0

import sys

sys.dont_write_bytecode = True

import json
import pathlib

import requests
from tqdm import tqdm

from config import GH_TOKEN

# Configure GitHub session
session = requests.Session()
session.headers.update({'Authorization': f'token {GH_TOKEN}'})


class FileWithCallback:
    def __init__(self, fd, callback):
        self.fd = fd
        self.callback = callback

    def get_colour(self, percentage):
        if percentage < 50:
            return 'RED'
        elif percentage < 90:
            return 'YELLOW'
        else:
            return 'GREEN'

    def read(self, chunk_size):
        data = self.fd.read(chunk_size)
        self.callback.update(len(data))
        if hasattr(self.callback, 'n') and hasattr(self.callback, 'total'):
            percentage = (self.callback.n / self.callback.total) * 100
            self.callback.colour = self.get_colour(percentage)
        return data


def create_git_release(GH_OWNER, GH_REPO, data):
    response = session.post(
        f'https://api.github.com/repos/{GH_OWNER}/{GH_REPO}/releases',
        headers={'Content-Type': 'application/json'},
        data=json.dumps(data),
    )
    response.raise_for_status()
    return response


def upload_asset(GH_OWNER, GH_REPO, release_id, asset_path):
    path = pathlib.Path(asset_path)
    file_size = path.stat().st_size
    asset_name = path.name

    with path.open('rb') as f:
        with tqdm(
            total=file_size,
            unit='B',
            unit_scale=True,
            colour='RED',
            bar_format='{percentage:3.0f}%|{bar:25}| {n_fmt}/{total_fmt} [{rate_fmt}]',
            ascii='-#',
        ) as pbar:
            progress_file = FileWithCallback(f, pbar)

            response = session.post(
                f'https://uploads.github.com/repos/{GH_OWNER}/{GH_REPO}/releases/{release_id}/assets?name={asset_name}',
                headers={
                    'Content-Type': 'application/octet-stream',
                    'Content-Length': str(file_size),
                },
                data=progress_file,
            )

            response.raise_for_status()

            return response
