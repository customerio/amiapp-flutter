package io.customer.amiapp_flutter

import io.customer.sdk.util.Logger

internal class AmiAppLogger() : Logger {
    internal val logsCache = mutableListOf<String>()

    fun clearLogs() {
        logsCache.clear()
    }

    override fun debug(message: String) {
        logsCache.add(message)
        android.util.Log.d(TAG, message)
    }

    override fun error(message: String) {
        logsCache.add(message)
        android.util.Log.e(TAG, message)
    }

    override fun info(message: String) {
        logsCache.add(message)
        android.util.Log.i(TAG, message)
    }

    companion object {
        private const val TAG = "[CIO]"
    }
}
