/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package org.lineageos.noimebar.utils

import android.content.Context

private const val PREFS_NAME = "no_ime_bar_preferences"

fun putInt(context: Context, key: String, value: Int) {
    context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit().putInt(key, value).apply()
}

fun getInt(context: Context, key: String, defaultValue: Int): Int {
    return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).getInt(key, defaultValue)
}
