import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_expense/main.dart';
import 'package:my_expense/services/alert_service.dart';
import 'package:my_expense/services/card_service.dart';
import 'package:my_expense/services/cash_service.dart';
import 'package:my_expense/services/sms_service.dart';
import 'package:my_expense/services/template_service.dart';
import 'package:my_expense/services/txn_service.dart';

class InitPage extends StatefulWidget {
  const InitPage({super.key});

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    log("init SMS");

    if (context.mounted) {
      if (await dbService.initDB()) {
        smsService = SmsService(dbService: dbService);
        await smsService.requestPermissionsAndInitialize();

        cardService = CardService(dbService: dbService);
        cashService = CashService(dbService: dbService);
        transactionService = TransactionService(dbService: dbService);
        templateService = TemplateService(dbService: dbService);
        smsService.syncFromSharedPreference();
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        AlertService.singleButtonAlertDialog(
          "Unable to access the DB. Please exit the app and try again or contact the developer!!",
          true,
          context,
          () {
            Navigator.pop(context);
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(strokeWidth: 5),
        ),
      ),
    );
  }
}
