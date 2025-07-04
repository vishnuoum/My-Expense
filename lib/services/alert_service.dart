import 'package:flutter/material.dart';

class AlertService {
  static Future<void> singleButtonAlertDialog(
    String text,
    bool isBarrierDismissible,
    BuildContext context,
    Function action,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: isBarrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text(text)]),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                action();
              },
            ),
          ],
        );
      },
    );
  }
}
