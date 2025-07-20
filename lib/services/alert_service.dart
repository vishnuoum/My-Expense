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

  static Future<void> twoButtonAlertDialog(
    String text,
    bool isBarrierDismissible,
    BuildContext context,
    String button1,
    Function action1,
    String button2,
    Function action2,
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
              child: Text(button1),
              onPressed: () {
                action1();
              },
            ),
            TextButton(
              child: Text(button2),
              onPressed: () {
                action2();
              },
            ),
          ],
        );
      },
    );
  }

  static void showLoading(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: SizedBox(
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                valueColor: AlwaysStoppedAnimation(Colors.black),
              ),
            ),
            SizedBox(height: 10),
            Text("Loading"),
          ],
        ),
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopScope(canPop: false, child: alert);
      },
    );
  }
}
