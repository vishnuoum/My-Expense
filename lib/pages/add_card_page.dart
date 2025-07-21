import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_expense/entity/tbl_card.dart';
import 'package:my_expense/main.dart';
import 'package:my_expense/models/card_details.dart';
import 'package:my_expense/models/response.dart';
import 'package:my_expense/services/alert_service.dart';

class AddCardPage extends StatefulWidget {
  final CardDetails cardDetails;
  const AddCardPage({super.key, required this.cardDetails});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  late CardDetails cardDetails;
  late TextEditingController billDay;
  late TextEditingController cardLimit;
  late TextEditingController cardName;
  late TextEditingController cardNo;
  final RegExp dayRegex = RegExp(r'^(0?[1-9]|[12][0-9]|3[01])$');

  bool isNew = false;

  @override
  void initState() {
    cardDetails = widget.cardDetails;
    isNew = cardDetails.cardNum.isEmpty;
    billDay = TextEditingController(
      text: cardDetails.billDay == 0 ? "" : cardDetails.billDay.toString(),
    );
    cardLimit = TextEditingController(
      text: cardDetails.cardLimit == 0
          ? ""
          : cardDetails.cardLimit.toStringAsFixed(2),
    );
    cardName = TextEditingController(text: cardDetails.cardName);
    cardNo = TextEditingController(text: cardDetails.cardNum);
    super.initState();
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

  Future<void> updateCardDetails({
    required int id,
    required String num,
    required String name,
    required double limit,
    required int day,
  }) async {
    cardDetails.id = id;
    cardDetails.cardNum = num;
    cardDetails.cardName = name;
    cardDetails.cardLimit = limit;
    cardDetails.billDay = day;
    DateTime nextBillDate = cardService.getNextBillDate(cardDetails.billDay);
    cardDetails.nextBillDate = DateFormat("dd/MM/yyyy").format(nextBillDate);
    cardDetails.daysToNextBill = nextBillDate.difference(DateTime.now()).inDays;
    cardDetails.creditUsage = await cardService.getCreditUsage(num, limit);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.pop(context, cardDetails);
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: ListView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          children: [
            Text(
              "${widget.cardDetails.cardNum.isEmpty ? "Add" : "Edit"} Card",
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
                  Text("Bill Day"),
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
                      controller: billDay,
                      maxLength: 2,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Bill Day of card (1-31)",
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
                        String day = billDay.text.trim();
                        String limit = cardLimit.text.trim();
                        String name = cardName.text.trim();
                        String num = cardNo.text.trim();
                        if (day.isEmpty ||
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
                        } else if (!dayRegex.hasMatch(day)) {
                          AlertService.singleButtonAlertDialog(
                            "Please provide a valid bill day (1-31)",
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
                            cardLimit: double.parse(limit),
                            billDay: int.parse(day),
                          );
                          if (cardDetails.id != -1) {
                            card.id = cardDetails.id;
                          }
                          Response addCardResponse = await cardService.addCard(
                            card,
                          );
                          if (!addCardResponse.isException) {
                            await updateCardDetails(
                              id: addCardResponse.responseBody as int,
                              num: num,
                              name: name,
                              limit: card.cardLimit,
                              day: card.billDay,
                            );
                            Navigator.pop(context);
                            AlertService.singleButtonAlertDialog(
                              "Card ${isNew ? "Added" : "Updated"} Successfully",
                              false,
                              context,
                              () {
                                Navigator.pop(context);
                                Navigator.pop(context, cardDetails);
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
                        isNew ? "ADD" : "UPDATE",
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
      ),
    );
  }
}
