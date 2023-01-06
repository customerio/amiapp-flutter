package io.customer.amiapp_flutter

import io.customer.sdk.CustomerIO
import io.customer.sdk.util.Logger
import io.customer.messagingpush.provider.FCMTokenProviderImpl

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val customerIOInstance: CustomerIO by lazy { CustomerIO.instance() }
    private val amiAppLogger: AmiAppLogger by lazy { AmiAppLogger(logger = customerIOInstance.diGraph.logger) }
    private var deviceToken: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        configureCustomerIOChannel(flutterEngine)
    }

    private fun configureCustomerIOChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CUSTOMER_IO_CHANNEL,
        ).setMethodCallHandler { call, result ->
            // This method is invoked on the main thread.
            when (call.method) {
                "captureLogs" -> result.success(captureLogs())
                "getLogs" -> result.success(getLogs())
                "clearLogs" -> result.success(clearLogs())
                "getUserAgent" -> result.success(getUserAgent())
                "updateDeviceToken" -> result.success(updateDeviceToken())
                "getDeviceToken" -> result.success(getDeviceToken())
                else -> result.notImplemented()
            }
        }
    }

    private fun captureLogs(): Any? {
        customerIOInstance.diGraph.overrideDependency(Logger::class.java, amiAppLogger)
        updateDeviceToken()
        return null
    }

    private fun getLogs(): List<String> {
        return amiAppLogger.cachedLogs
    }

    private fun clearLogs(): Any? {
        amiAppLogger.clearLogs()
        return null
    }

    private fun getUserAgent(): String? {
        return "User agent will be shown here"
    }

    private fun updateDeviceToken(): Any? {
        val fcmTokenProvider = FCMTokenProviderImpl(
            logger = customerIOInstance.diGraph.logger,
            context = this,
        )
        fcmTokenProvider.getCurrentToken { token ->
            deviceToken = token
        }
        return null
    }

    private fun getDeviceToken(): String? {
        updateDeviceToken()
        return deviceToken
    }

    companion object {
        private const val CUSTOMER_IO_CHANNEL = "io.customer.amiapp_flutter/customer_io"
    }
}
