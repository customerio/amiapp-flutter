package io.customer.amiapp_flutter

import io.customer.sdk.util.Logger

internal class AmiAppLogger(
    private val logger: Logger,
) : Logger {
    internal val logsCache = mutableListOf<String>()

    fun clearLogs() {
        logsCache.clear()
    }

    override fun debug(message: String) {
        logsCache.add(message)
        logger.debug(message)
    }

    override fun error(message: String) {
        logsCache.add(message)
        logger.error(message)
    }

    override fun info(message: String) {
        logsCache.add(message)
        logger.error(message)
    }
}
