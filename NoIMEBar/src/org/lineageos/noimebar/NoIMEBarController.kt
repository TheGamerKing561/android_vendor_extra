/*
 * SPDX-FileCopyrightText: 2025 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package org.lineageos.noimebar

import android.content.Context
import android.content.om.FabricatedOverlay
import android.content.om.OverlayIdentifier
import android.content.om.OverlayManager
import android.content.om.OverlayManagerTransaction
import android.os.UserHandle
import android.util.Log
import android.util.TypedValue
import org.lineageos.noimebar.utils.getInt
import org.lineageos.noimebar.utils.putInt

object NoIMEBarController {

    private const val TAG = "NoIMEBarController"
    private const val KEY_NO_IME_BAR_ENABLE = "no_ime_bar_enable"
    private const val OVERLAY_NAME = "no_ime_bar"

    /*
     * Enable or disable hiding the IME navigation bar
     * @return puts the value in place
     */
    fun setNoIMEBarEnabled(context: Context, enabled: Boolean) {
        putInt(context, KEY_NO_IME_BAR_ENABLE, if (enabled) 1 else 0)
        applySettings(context, enabled)
    }

    /*
     * Check whether hiding the IME navigation bar is enabled
     * @return boolean state
     */
    fun isNoIMEBarEnabled(context: Context): Boolean {
        return getInt(context, KEY_NO_IME_BAR_ENABLE, 0) == 1
    }

    /*
     * Apply the overlay settings to framework-res
     * @return puts the value in place
     */
    fun applySettings(context: Context, enabled: Boolean) {
        val om = context.getSystemService(OverlayManager::class.java) ?: return
        try {
            val userId = UserHandle.myUserId()
            val transaction = OverlayManagerTransaction.Builder()
            val overlayId = OverlayIdentifier(context.packageName, OVERLAY_NAME)

            if (enabled) {
                val overlay =
                    FabricatedOverlay(OVERLAY_NAME, "android").apply {
                        setOwningPackage(context.packageName)
                        setResourceValue(
                            "android:bool/config_imeDrawsImeNavBar",
                            TypedValue.TYPE_INT_BOOLEAN,
                            0,
                            null,
                        )
                        setResourceValue(
                            "android:bool/config_hideNavBarForKeyboard",
                            TypedValue.TYPE_INT_BOOLEAN,
                            1,
                            null,
                        )
                        setResourceValue(
                            "android:dimen/navigation_bar_frame_height",
                            0f,
                            TypedValue.COMPLEX_UNIT_DIP,
                            null,
                        )
                        setResourceValue(
                            "android:dimen/input_method_navigation_bar_height",
                            0f,
                            TypedValue.COMPLEX_UNIT_DIP,
                            null,
                        )
                    }

                transaction.registerFabricatedOverlay(overlay)
                transaction.setEnabled(overlayId, true, userId)
            } else {
                transaction.setEnabled(overlayId, false, userId)
                transaction.unregisterFabricatedOverlay(overlayId)
            }

            om.commit(transaction.build())
        } catch (e: Exception) {
            Log.e(TAG, "Failed to apply NoIMEBar settings", e)
        }
    }

    /*
     * Restore settings on boot / resume
     * @return puts the value in place
     */
    fun restoreSettings(context: Context) {
        val enabled = isNoIMEBarEnabled(context)
        applySettings(context, enabled)
    }
}
