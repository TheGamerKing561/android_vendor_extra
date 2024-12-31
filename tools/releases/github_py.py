#!/usr/bin/python3
# Copyright (C) 2024 Giovanni Ricca
# SPDX-License-Identifier: Apache-2.0

import sys

sys.dont_write_bytecode = True

import json
import pathlib

import requests
from config import GH_TOKEN
from tqdm import tqdm

# Configure GitHub
session = requests.Session()
session.headers.update({'Authorization': f'token {GH_TOKEN}'})


class FileWithCallback:
    def __init__(self, fd, callback):
        self.fd = fd
        self.callback = callback

    def read(self, size):
        chunk = self.fd.read(size)
        if chunk:
            self.callback(len(chunk))
        return chunk


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
        pbar = tqdm(
            total=file_size,
            unit='B',
            unit_scale=True,
            colour='RED',
            bar_format='{percentage:3.0f}%|{bar:25}| {n_fmt}/{total_fmt} [{rate_fmt}]',
            ascii='-#',
        )

        def get_colour(percentage):
            if percentage < 50:
                return 'RED'  # Red
            elif percentage < 90:
                return 'YELLOW'  # Yellow
            else:
                return 'GREEN'  # Green

        def update_progress_bar(chunk_size):
            pbar.update(chunk_size)
            pbar.colour = get_colour(pbar.n / pbar.total * 100)

        response = session.post(
            f'https://uploads.github.com/repos/{GH_OWNER}/{GH_REPO}/releases/{release_id}/assets?name={asset_name}',
            headers={
                'Content-Type': 'application/octet-stream',
                'Content-Length': str(file_size),
            },
            data=FileWithCallback(f, update_progress_bar),
        )

        pbar.close()
        response.raise_for_status()
        return response
