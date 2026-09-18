/*
 * SPDX-FileCopyrightText: The LineageOS Project
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
            updateTile()
        }
    }
}
