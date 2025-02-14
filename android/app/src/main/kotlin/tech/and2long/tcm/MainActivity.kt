package tech.and2long.tcm

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var binaryMessenger: BinaryMessenger? = null

    private companion object {
        private const val TAG = "MainActivity"

        private const val CHANNEL_COMMON_METHOD = "tcm_common_method"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "onCreate: ")
        initCommonChannel()
    }

    private fun initCommonChannel() {
        binaryMessenger?.let {
            MethodChannel(it, CHANNEL_COMMON_METHOD).setMethodCallHandler(
                CommonMethodCallHandler(this)
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d(TAG, "configureFlutterEngine: ")
        binaryMessenger = flutterEngine.dartExecutor.binaryMessenger
    }
}