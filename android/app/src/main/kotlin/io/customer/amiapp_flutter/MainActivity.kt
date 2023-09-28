package io.customer.amiapp_flutter

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onNewIntent(intent: Intent) {
        (application as MainApplication).lifecycleEventsListener.logEvent("onNewIntent", this)
        super.onNewIntent(intent)
    }
}