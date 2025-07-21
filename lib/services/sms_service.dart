import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_expense/entity/tbl_template.dart';
import 'package:my_expense/entity/tbl_transaction.dart';
import 'package:my_expense/main.dart';
import 'package:my_expense/models/response.dart';
import 'package:my_expense/services/db_service.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  MethodChannel platform = MethodChannel('sms_channel');

  DBService dbService;
  DateFormat dbDateFormat = DateFormat("yyyy-mm-dd");
  SmsService({required this.dbService});

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
        checkAndUpdateDB(message);
      }
    });

    log("Listening for messages");
  }

  Future<void> syncFromSharedPreference() async {
    log("Inside sync method");
    String? cachedSMS = await getCachedSmsFromNative();
    if (cachedSMS == null) return;
    List<String> messages = List<String>.from(jsonDecode(cachedSMS));
    log("Cached sms: $messages");
    for (String message in messages) {
      checkAndUpdateDB(message);
    }
    await deleteCachedMessage();
  }

  Future<String?> getCachedSmsFromNative() async {
    const platform = MethodChannel('sms_channel');
    try {
      final String? cachedJson = await platform.invokeMethod<String>(
        'getCachedSms',
      );
      return cachedJson;
    } on PlatformException catch (e) {
      log("Failed to get SMS from native: ${e.message}");
      return null;
    }
  }

  Future<void> deleteCachedMessage() async {
    const platform = MethodChannel('sms_channel');
    try {
      await platform.invokeMethod<String>('deleteCachedSms');
    } on PlatformException catch (e) {
      log("Failed to get SMS from native: ${e.message}");
    }
  }

  Future<void> checkAndUpdateDB(String message) async {
    if (!message.toLowerCase().contains("bank")) return;

    Response templateResponse = await getTemplatesFromDB();
    if (templateResponse.isException) return;
    List<TblTemplate> templates = templateResponse.responseBody;

    for (TblTemplate template in templates) {
      try {
        final match = template.pattern.firstMatch(message);
        if (match != null) {
          Map<String, dynamic> txnMap = {};
          txnMap["txnType"] = template.txnType;
          txnMap["amount"] = double.tryParse(
            match.group(template.amountGroup) ?? "",
          );
          txnMap["uniqueId"] = match.group(template.uniqueIdGroup);
          String formattedDate = dbDateFormat.format(
            DateFormat(
              template.dateFormat,
            ).parse(match.group(template.dateGroup).toString()),
          );
          txnMap["date"] = formattedDate;
          txnMap["merchant"] = match.group(template.merchantGroup);
          txnMap["isCredit"] = template.isCredit;

          if (null == txnMap["amount"]) continue;

          TblTransactions transaction = TblTransactions.fromMap(txnMap);
          transactionService.addTransaction(transaction);
        }
      } catch (error) {
        log("Error while parsing message $error");
      }
    }
  }

  Future<Response> getTemplatesFromDB() async {
    return await templateService.getAllTemplates();
  }
}
