package io.customer.amiapp_flutter

import android.util.Log

import io.customer.sdk.util.CioLogLevel
import io.customer.sdk.util.Logger

class AmiAppLogger(private val initialLogLevel: CioLogLevel = CioLogLevel.DEBUG) : Logger {
    // Log level defined by user in configurations
    private var userDefinedLogLevel: CioLogLevel? = null

    // Prefer user log level; fallback to default only till the user defined value is not received
    private val logLevel: CioLogLevel
        get() = userDefinedLogLevel ?: initialLogLevel

    // List of logs for caching and displaying later
    internal val logsCache = mutableListOf<String>()

    fun setUserDefinedLogLevel(logLevel: CioLogLevel?) {
        userDefinedLogLevel = logLevel
    }

    fun clearLogs() {
        logsCache.clear()
    }

    override fun info(message: String) {
        log(CioLogLevel.INFO, message) {
            Log.i(TAG, message)
        }
    }

    override fun debug(message: String) {
        log(CioLogLevel.DEBUG, message) {
            Log.d(TAG, message)
        }
    }

    override fun error(message: String) {
        log(CioLogLevel.ERROR, message) {
            Log.e(TAG, message)
        }
    }

    private fun log(levelForMessage: CioLogLevel, message: String, block: () -> Unit) {
        if (logLevel.shouldLog(levelForMessage)) {
            block()
            logsCache.add(message)
        }
    }

    companion object {
        const val TAG = "[CIO]"
    }
}
