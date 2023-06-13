package io.customer.amiapp_flutter

import io.customer.sdk.CustomerIO
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
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
                "getUserAgent" -> result.success(getUserAgent())
                else -> result.notImplemented()
            }
        }
    }

    private fun getUserAgent(): String {
        return "AmiApp (Flutter)" +
                " - SDK v${CustomerIO.instance().sdkVersion}" +
                " - App v${BuildConfig.VERSION_NAME} (${BuildConfig.VERSION_CODE})"
    }

    companion object {
        private const val CUSTOMER_IO_CHANNEL = "io.customer.amiapp_flutter/customer_io"
    }
}
