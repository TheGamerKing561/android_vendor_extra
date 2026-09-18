/*
 * SPDX-FileCopyrightText: 2025 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package org.lineageos.noimebar

import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

class NoIMEBarTileService : TileService() {

    override fun onStartListening() {
        super.onStartListening()
        updateQsState()
    }

    override fun onClick() {
        super.onClick()
        val currentState = NoIMEBarController.isNoIMEBarEnabled(this)

        NoIMEBarController.setNoIMEBarEnabled(this, !currentState)

        updateQsState()
    }

    private fun updateQsState() {
        val isEnabled = NoIMEBarController.isNoIMEBarEnabled(this)

        qsTile?.apply {
            state = if (isEnabled) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE
            subtitle = getString(if (isEnabled) R.string.status_hidden else R.string.status_visible)
            updateTile()
        }
    }
}
