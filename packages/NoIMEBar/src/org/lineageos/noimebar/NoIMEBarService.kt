/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package org.lineageos.noimebar

import android.content.Context
import android.content.om.FabricatedOverlay
import android.content.om.OverlayIdentifier
import android.content.om.OverlayManagerTransaction
import android.os.UserHandle
import android.util.TypedValue

object NoIMEBarService {

    const val OVERLAY = "no_ime_bar"

    fun createTransaction(context: Context, enabled: Boolean): OverlayManagerTransaction {
        val overlayId = OverlayIdentifier(context.packageName, OVERLAY)
        val userId = UserHandle.myUserId()

        return OverlayManagerTransaction.Builder()
            .apply {
                if (enabled) {
                    registerFabricatedOverlay(createOverlay(context))
                    setEnabled(overlayId, true, userId)
                } else {
                    setEnabled(overlayId, false, userId)
                    unregisterFabricatedOverlay(overlayId)
                }
            }
            .build()
    }

    private fun createOverlay(context: Context): FabricatedOverlay =
        FabricatedOverlay(OVERLAY, "android").apply {
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
}
