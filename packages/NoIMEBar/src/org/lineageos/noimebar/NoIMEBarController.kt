/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package org.lineageos.noimebar

import android.content.Context
import android.content.om.OverlayManager
import android.util.Log
import org.lineageos.noimebar.utils.getInt
import org.lineageos.noimebar.utils.putInt

object NoIMEBarController {

    private const val TAG = "NoIMEBarController"
    private const val KEY_NO_IME_BAR_ENABLE = NoIMEBarService.OVERLAY + "_enable"

    fun setNoIMEBarEnabled(context: Context, enabled: Boolean) {
        putInt(context, KEY_NO_IME_BAR_ENABLE, if (enabled) 1 else 0)
        applySettings(context, enabled)
    }

    fun isNoIMEBarEnabled(context: Context): Boolean {
        return getInt(context, KEY_NO_IME_BAR_ENABLE, 0) == 1
    }

    fun restoreSettings(context: Context) {
        applySettings(context, isNoIMEBarEnabled(context))
    }

    private fun applySettings(context: Context, enabled: Boolean) {
        val om = context.getSystemService(OverlayManager::class.java) ?: return

        try {
            om.commit(NoIMEBarService.createTransaction(context, enabled))
        } catch (e: Exception) {
            Log.e(TAG, "Failed to apply NoIMEBar settings", e)
        }
    }
}
