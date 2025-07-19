package com.example.my_expense

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log

class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            val fullMessage = messages.joinToString("") { it.messageBody }
            Log.d("SmsReceiver", "Received SMS: $fullMessage")

            val serviceIntent = Intent(context, SmsForegroundService::class.java)
            serviceIntent.putExtra("message", fullMessage)
            context.startForegroundService(serviceIntent)
        }
    }
}