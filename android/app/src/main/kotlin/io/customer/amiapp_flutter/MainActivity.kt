package io.customer.amiapp_flutter

import io.customer.base.internal.InternalCustomerIOApi
import io.customer.sdk.CustomerIO
import io.customer.sdk.CustomerIOShared
import io.customer.sdk.di.CustomerIOStaticComponent
import io.customer.sdk.di.DiGraph
import io.customer.sdk.util.Logger
import io.customer.messagingpush.provider.FCMTokenProviderImpl

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

@OptIn(InternalCustomerIOApi::class)
class MainActivity : FlutterActivity() {
    private val sdkStaticDIGraph: CustomerIOStaticComponent by lazy { CustomerIOStaticComponent() }

    // Creating new instance of [CustomerIOStaticComponent] as logger is lazy and will not be
    // overriden if accessed before from same instance
    private val amiAppLogger: AmiAppLogger by lazy { AmiAppLogger(logger = CustomerIOStaticComponent().logger) }
    private var deviceToken: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        configureCustomerIOChannel(flutterEngine)
    }

    private fun configureCustomerIOChannel(flutterEngine: FlutterEngine) {
        // Override logger at earliest to capture all logs
        sdkStaticDIGraph.overrideDependency(Logger::class.java, amiAppLogger)
        CustomerIOShared.createInstance(sdkStaticDIGraph)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CUSTOMER_IO_CHANNEL,
        ).setMethodCallHandler { call, result ->
            // This method is invoked on the main thread.
            when (call.method) {
                "onSDKInitialized" -> result.success(onSDKInitialized())
                "getLogs" -> result.success(getLogs())
                "clearLogs" -> result.success(clearLogs())
                "getUserAgent" -> result.success(getUserAgent())
                "updateDeviceToken" -> result.success(updateDeviceToken())
                "getDeviceToken" -> result.success(getDeviceToken())
                else -> result.notImplemented()
            }
        }
    }

    private fun onSDKInitialized(): Any? {
        updateDeviceToken()
        return null
    }

    private fun getLogs(): List<String> {
        return amiAppLogger.logsCache
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
            logger = sdkStaticDIGraph.logger,
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
