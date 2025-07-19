package com.example.my_expense

import android.app.*
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.os.Build
import android.os.IBinder
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.Toast
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors
import android.content.Context
import io.flutter.embedding.engine.FlutterEngineCache

class SmsForegroundService : Service() {

    private val channelId = "sms_channel_id"
    private val executor = Executors.newSingleThreadExecutor()
    private var engine: FlutterEngine? = null
    private val dbName = "sms.db"

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val message = intent?.getStringExtra("message") ?: return START_NOT_STICKY
        showNotification(message)

        executor.execute {
            // insertToDb(message)
            sendToFlutter(message)
        }

        return START_STICKY
    }

    private fun showNotification(content: String) {
        Log.d("SmsForegroundService", "Message received for notify");
        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "SMS Listener",
                NotificationManager.IMPORTANCE_LOW
            )
            notificationManager.createNotificationChannel(channel)
        }

        val notification = Notification.Builder(this, channelId)
            .setContentTitle("SMS Received")
            .setContentText(content.take(40))
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .build()

        startForeground(1, notification)
    }

    private fun insertToDb(message: String) {
        try {
            val db: SQLiteDatabase = openOrCreateDatabase(dbName, MODE_PRIVATE, null)
            db.execSQL("CREATE TABLE IF NOT EXISTS messages(id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT)")
            val stmt = db.compileStatement("INSERT INTO messages(content) VALUES(?)")
            stmt.bindString(1, message)
            stmt.execute()
            stmt.close()
            db.close()
            Log.d("SmsForegroundService", "Inserted to DB")
        } catch (e: Exception) {
            Log.e("SmsForegroundService", "DB Error: ${e.message}")
        }
    }

    private fun sendToFlutter(message: String) {
        if (!isAppInForeground()) {
            Log.d("SmsForegroundService", "App not in foreground. Skipping Flutter call.")
            return
        }
        try {
            Handler(Looper.getMainLooper()).post {
                // if(engine == null) {
                //     engine = FlutterEngine(this)
                //     engine!!.dartExecutor.executeDartEntrypoint(
                //         DartExecutor.DartEntrypoint.createDefault()
                //     )
                // }
                MethodChannel(FlutterEngineCache.getInstance().get("main_engine")!!.dartExecutor.binaryMessenger, "sms_channel")
                    .invokeMethod("onSmsReceived", message)
            }
        } catch (e: Exception) {
            Log.e("SmsForegroundService", "Flutter channel error: ${e.message}")
        }
    }

    private fun isAppInForeground(): Boolean {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val appProcesses = activityManager.runningAppProcesses
        val packageName = this.packageName
        for (appProcess in appProcesses) {
            if (appProcess.processName == packageName &&
                appProcess.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
                return true
            }
        }
        return false
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
