package com.example.my_expense


import android.os.Build
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.embedding.engine.FlutterEngineCache

class MainActivity : FlutterActivity() {
    // private val CHANNEL = "sms_channel"
    // private val REQUEST_CODE = 1001
    
    //  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    //     super.configureFlutterEngine(flutterEngine)
    //     GeneratedPluginRegistrant.registerWith(flutterEngine)
    //     MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
    //         call, result ->
    //         if (call.method == "requestDataSyncPermission") {
    //             Log.d("MainActivity", "Calling for permission")
    //             if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) { // Android 14 (API 34)
    //                 val permission = android.Manifest.permission.FOREGROUND_SERVICE_DATA_SYNC
    //                 if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
    //                     ActivityCompat.requestPermissions(this, arrayOf(permission), REQUEST_CODE)
    //                     result.success("requested")
    //                 } else {
    //                     result.success("already_granted")
    //                 }
    //             } else {
    //                 result.success("not_required")
    //             }
    //         } else {
    //             result.notImplemented()
    //         }
    //     }
    // }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        FlutterEngineCache.getInstance().put("main_engine", flutterEngine)
    }
}
