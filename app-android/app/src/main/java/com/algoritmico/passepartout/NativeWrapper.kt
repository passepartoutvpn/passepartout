// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

package com.algoritmico.passepartout
import android.util.Log

class NativeWrapper {
    external fun partoutVersion(): String

    companion object {
        init {
            try {
                // Name of the NDK .so without "lib" prefix or ".so"
                System.loadLibrary("PassepartoutNative")
            } catch (e: Exception) {
                Log.e("Passepartout", e.localizedMessage ?: "")
            }
        }
    }
}