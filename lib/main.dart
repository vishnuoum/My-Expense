import 'package:flutter/material.dart';
import 'package:my_expense/entity/tbl_template.dart';
import 'package:my_expense/entity/tbl_transaction.dart';
import 'package:my_expense/models/card_details.dart';
import 'package:my_expense/models/transaction_listing_details.dart';
import 'package:my_expense/pages/add_card_page.dart';
import 'package:my_expense/pages/add_template_page.dart';
import 'package:my_expense/pages/add_txn_page.dart';
import 'package:my_expense/pages/all_txn_page.dart';
import 'package:my_expense/pages/home_page.dart';
import 'package:my_expense/pages/init.dart';
import 'package:my_expense/pages/template_page.dart';
import 'package:my_expense/services/card_service.dart';
import 'package:my_expense/services/cash_service.dart';
import 'package:my_expense/services/db_service.dart';
import 'package:my_expense/services/sms_service.dart';
import 'package:my_expense/services/template_service.dart';
import 'package:my_expense/services/txn_service.dart';
import 'package:my_expense/theme.dart';
import 'package:my_expense/theme_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

final ThemeController themeController = ThemeController();
final DBService dbService = DBService();
late CardService cardService;
late CashService cashService;
late SmsService smsService;
late TemplateService templateService;
late TransactionService transactionService;

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (_, mode, __) {
        return MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          routes: {
            '/addCard': (context) => AddCardPage(
              cardDetails:
                  ModalRoute.of(context)!.settings.arguments as CardDetails,
            ),
            '/addTxn': (context) => AddTxnPage(
              transactionDetails:
                  ModalRoute.of(context)!.settings.arguments as TblTransactions,
            ),
            '/addTemplate': (context) => AddTemplatePage(
              template:
                  ModalRoute.of(context)!.settings.arguments as TblTemplate,
            ),
            '/allTransactions': (context) => AllTxnPage(
              transactionDetails:
                  ModalRoute.of(context)!.settings.arguments
                      as TransactionListingDetails,
            ),
            '/template': (context) => TemplatePage(),
            '/home': (context) => HomePage(),
            "/": (context) => InitPage(),
          },
          initialRoute: "/",
        );
      },
    );
  }
}
