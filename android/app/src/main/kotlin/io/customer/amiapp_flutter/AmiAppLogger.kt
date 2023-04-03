package io.customer.amiapp_flutter

import android.util.Log

import io.customer.sdk.util.CioLogLevel
import io.customer.sdk.util.Logger

class AmiAppLogger : Logger {
    // Log level defined by user in configurations
    private var preferredLogLevel: CioLogLevel? = null

    // Prefer user log level; fallback to default only till the user defined value is not received
    val logLevel: CioLogLevel
        get() = preferredLogLevel ?: CioLogLevel.DEBUG

    // List of logs for caching and displaying later
    internal val logsCache = mutableListOf<String>()

    fun setPreferredLogLevel(logLevel: CioLogLevel?) {
        preferredLogLevel = logLevel
    }

    fun clearLogs() {
        logsCache.clear()
    }

    override fun info(message: String) {
        runIfMeetsLogLevelCriteria(CioLogLevel.INFO, message) {
            Log.i(TAG, message)
        }
    }

    override fun debug(message: String) {
        runIfMeetsLogLevelCriteria(CioLogLevel.DEBUG, message) {
            Log.d(TAG, message)
        }
    }

    override fun error(message: String) {
        runIfMeetsLogLevelCriteria(CioLogLevel.ERROR, message) {
            Log.e(TAG, message)
        }
    }

    private fun runIfMeetsLogLevelCriteria(
        levelForMessage: CioLogLevel,
        message: String,
        block: () -> Unit,
    ) {
        val shouldLog = logLevel.shouldLog(levelForMessage)
        logsCache.add(message)
        if (shouldLog) block()
    }

    companion object {
        const val TAG = "[CIO]"
    }
}
