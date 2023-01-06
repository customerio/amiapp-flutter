package io.customer.amiapp_flutter

import io.customer.sdk.util.Logger

internal class AmiAppLogger(
    private val logger: Logger,
) : Logger {
    internal val cachedLogs = mutableListOf<String>()

    fun clearLogs() {
        cachedLogs.clear()
    }

    override fun debug(message: String) {
        cachedLogs.add(message)
        logger.debug(message)
    }

    override fun error(message: String) {
        cachedLogs.add(message)
        logger.error(message)
    }

    override fun info(message: String) {
        cachedLogs.add(message)
        logger.error(message)
    }
}
