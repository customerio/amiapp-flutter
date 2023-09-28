package io.customer.amiapp_flutter

import io.flutter.app.FlutterApplication

class MainApplication : FlutterApplication() {

    lateinit var lifecycleEventsListener: ActivityLifecycleEventsListener

    override fun onCreate() {
        super.onCreate()
        lifecycleEventsListener = ActivityLifecycleEventsListener()
        registerActivityLifecycleCallbacks(lifecycleEventsListener)
    }
}
