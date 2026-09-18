/*
 * SPDX-FileCopyrightText: 2025 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

package org.lineageos.noimebar.utils

import android.content.Context

private const val PREFS_NAME = "no_ime_bar_preferences"

/*
 * Stores an integer value in SharedPreferences
 * @return puts the value in place
 */
fun putInt(context: Context, key: String, value: Int) {
    context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit().putInt(key, value).apply()
}

/*
 * Retrieves an integer value from SharedPreferences
 * @return the value
 */
fun getInt(context: Context, key: String, defaultValue: Int): Int {
    return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).getInt(key, defaultValue)
}
