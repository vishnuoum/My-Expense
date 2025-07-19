import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  MethodChannel platform = MethodChannel('sms_channel');

  Future<void> requestPermissionsAndInitialize() async {
    var smsStatus = await Permission.sms.status;
    if (!smsStatus.isGranted) {
      smsStatus = await Permission.sms.request();
    }

    var backgroundStatus = await Permission.ignoreBatteryOptimizations.status;
    if (!backgroundStatus.isGranted) {
      backgroundStatus = await Permission.ignoreBatteryOptimizations.request();
    }
    // final result = await platform.invokeMethod("requestDataSyncPermission");
    if (smsStatus.isGranted && backgroundStatus.isGranted
    // (result == "already_granted" || result == "not_required")
    ) {
      startListeningToSms();
    } else {
      log("Permissions not granted");
    }
  }

  void startListeningToSms() {
    platform.setMethodCallHandler((call) async {
      if (call.method == "onSmsReceived") {
        var message = call.arguments as String;
        log("New SMS logged $message");
      }
    });

    log("Listening for messages");
  }

  Future<void> syncFromSharedPreference() async {
    log("Inside sync method");
    String? cachedSMS = await getCachedSmsFromNative();
    log("Cached sms: $cachedSMS");
  }

  Future<String?> getCachedSmsFromNative() async {
    const platform = MethodChannel('sms_channel');
    try {
      final String? cachedJson = await platform.invokeMethod<String>(
        'getCachedSms',
      );
      return cachedJson;
    } on PlatformException catch (e) {
      print("Failed to get SMS from native: ${e.message}");
      return null;
    }
  }
}
