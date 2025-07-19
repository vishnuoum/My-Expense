import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:my_expense/entity/tbl_template.dart';
import 'package:my_expense/entity/tbl_transaction.dart';
import 'package:my_expense/main.dart';
import 'package:my_expense/models/response.dart';
import 'package:my_expense/services/db_service.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  MethodChannel platform = MethodChannel('sms_channel');

  DBService dbService;
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
        checkAndUpdateDB(message.toLowerCase());
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
      log("Failed to get SMS from native: ${e.message}");
      return null;
    }
  }

  Future<void> checkAndUpdateDB(String message) async {
    if (!message.contains("bank")) return;

    Response templateResponse = await getTemplatesFromDB();
    if (templateResponse.isException) return;
    List<TblTemplate> templates = templateResponse.responseBody;

    for (TblTemplate template in templates) {
      final match = template.pattern.firstMatch(message);
      if (match != null) {
        Map<String, dynamic> txnMap = {};
        txnMap["txnType"] = getSmsTxnType(message);
        txnMap["amount"] = double.tryParse(
          match.group(template.amountGroup) ?? "",
        );
        txnMap["uniqueId"] = match.group(template.uniqueIdGroup);
        txnMap["date"] = match.group(template.dateGroup);
        txnMap["merchant"] = match.group(template.merchantGroup);
        txnMap["txnNature"] = match.group(template.txnNatureGroup);
        txnMap["isCredit"] = getIsCredit(txnMap["txnNature"]);

        if (null == txnMap["amount"]) continue;

        TblTransactions transaction = TblTransactions.fromMap(txnMap);
        transactionService.addTransaction(transaction);
      }
    }
  }

  int getIsCredit(String txnNature) {
    if (txnNature == "credited" || txnNature == "spent") return 1;
    return 0;
  }

  String getSmsTxnType(String message) {
    if (message.contains("credit card") || message.contains("card")) {
      return "card";
    }
    return "cash";
  }

  Future<Response> getTemplatesFromDB() async {
    return await dbService.getTemplates();
  }
}
