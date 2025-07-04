import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_expense/entity/tbl_card.dart';
import 'package:my_expense/main.dart';
import 'package:my_expense/services/alert_service.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  DateFormat dateFormat = DateFormat("dd/MM/yyyy");
  TextEditingController billDate = TextEditingController(
    text: DateFormat("dd/MM/yyyy").format(DateTime.now()),
  );
  TextEditingController cardLimit = TextEditingController(text: "");
  TextEditingController cardName = TextEditingController(text: "");
  TextEditingController cardNo = TextEditingController(text: "");

  Future<void> selectDate() async {
    selectedDate = (await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    ))!;
    setState(() {
      billDate.text = dateFormat.format(selectedDate);
    });
  }

  showLoading(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        children: [
          Text(
            "Add Card",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          SizedBox(height: 30),
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Card Name"),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: themeController.value == ThemeMode.dark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                  ),
                  child: TextFormField(
                    controller: cardName,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Card name",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Text("Card no. (4 digits)"),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: themeController.value == ThemeMode.dark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                  ),
                  child: TextFormField(
                    controller: cardNo,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Card no.",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                    buildCounter:
                        (
                          BuildContext context, {
                          required int currentLength,
                          required bool isFocused,
                          required int? maxLength,
                        }) {
                          return null; // Completely hides the counter widget
                        },
                  ),
                ),
                SizedBox(height: 15),
                Text("Next Bill Date"),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: themeController.value == ThemeMode.dark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                  ),
                  child: TextFormField(
                    readOnly: true,
                    controller: billDate,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Date",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                    onTap: () async {
                      await selectDate();
                    },
                  ),
                ),
                SizedBox(height: 15),
                Text("Card limit"),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: themeController.value == ThemeMode.dark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                  ),
                  child: TextFormField(
                    controller: cardLimit,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Card limit",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      String date = billDate.text;
                      String limit = cardLimit.text;
                      String name = cardName.text;
                      String num = cardNo.text;
                      if (date.isEmpty ||
                          limit.isEmpty ||
                          name.isEmpty ||
                          num.isEmpty) {
                        AlertService.singleButtonAlertDialog(
                          "Please complete the form",
                          true,
                          context,
                          () {
                            Navigator.pop(context);
                          },
                        );
                      } else if (num.length != 4) {
                        AlertService.singleButtonAlertDialog(
                          "Please enter last 4 digits of your card number",
                          true,
                          context,
                          () {
                            Navigator.pop(context);
                          },
                        );
                      } else {
                        showLoading(context);
                        TblCards card = TblCards(
                          cardNo: num,
                          cardName: name,
                          cardLimit: limit,
                          billDay: DateFormat("dd/MM/yyyy").parse(date).day,
                        );
                        if (await dbService.addCard(card)) {
                          Navigator.pop(context);
                          AlertService.singleButtonAlertDialog(
                            "Card Added Successfully",
                            false,
                            context,
                            () {
                              Navigator.popUntil(
                                context,
                                ModalRoute.withName('/home'),
                              );
                            },
                          );
                        } else {
                          Navigator.pop(context);
                          AlertService.singleButtonAlertDialog(
                            "Error while saving card. Try again",
                            true,
                            context,
                            () {
                              Navigator.pop(context);
                            },
                          );
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "ADD",
                      style: TextStyle(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
