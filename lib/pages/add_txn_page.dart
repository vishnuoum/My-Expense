import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_expense/entity/tbl_transaction.dart';
import 'package:my_expense/main.dart';
import 'package:my_expense/services/alert_service.dart';

class AddTxnPage extends StatefulWidget {
  final TblTransactions transactionDetails;
  const AddTxnPage({super.key, required this.transactionDetails});

  @override
  State<AddTxnPage> createState() => _AddTxnPageState();
}

class _AddTxnPageState extends State<AddTxnPage> {
  final formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  DateFormat dateFormat = DateFormat("dd/MM/yyyy");
  late TextEditingController billDate;
  late TextEditingController category;
  late TextEditingController amount;
  late TextEditingController merchant;

  late TblTransactions transactionDetails;

  List<TblTransactions> addedTxns = [];

  @override
  void initState() {
    transactionDetails = widget.transactionDetails;
    billDate = TextEditingController(
      text: transactionDetails.date.isNotEmpty
          ? dateFormat.format(
              DateFormat("yyyy-MM-dd").parse(transactionDetails.date),
            )
          : dateFormat.format(DateTime.now()),
    );
    category = TextEditingController(text: transactionDetails.category);
    amount = TextEditingController(
      text: transactionDetails.amount == 0
          ? ""
          : transactionDetails.amount.toStringAsFixed(2),
    );
    merchant = TextEditingController(text: transactionDetails.merchant);
    super.initState();
  }

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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.pop(context, addedTxns);
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: ListView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          children: [
            Text(
              "${transactionDetails.merchant.isEmpty ? "Add" : "Edit"} Transaction",
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
                  Text("Transaction Date"),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: themeController.value == ThemeMode.dark
                          ? Colors.grey[900]
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
                  Text("Amount"),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: themeController.value == ThemeMode.dark
                          ? Colors.grey[900]
                          : Colors.grey[200],
                    ),
                    child: TextFormField(
                      controller: amount,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Transaction Amount",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  Text("Merchant"),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: themeController.value == ThemeMode.dark
                          ? Colors.grey[900]
                          : Colors.grey[200],
                    ),
                    child: TextFormField(
                      controller: merchant,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Merchant",
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
                  Text("Category"),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: themeController.value == ThemeMode.dark
                          ? Colors.grey[900]
                          : Colors.grey[200],
                    ),
                    child: TextFormField(
                      controller: category,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Category",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () async {
                        String txnDate = billDate.text.trim();
                        String txnCategory = category.text.trim();
                        String txnAmount = amount.text.trim();
                        String txnMerchant = merchant.text.trim();
                        if (txnDate.isEmpty ||
                            txnCategory.isEmpty ||
                            txnAmount.isEmpty ||
                            txnMerchant.isEmpty) {
                          AlertService.singleButtonAlertDialog(
                            "Please complete the form",
                            true,
                            context,
                            () {
                              Navigator.pop(context);
                            },
                          );
                        } else if (double.parse(txnAmount) <= 0) {
                          AlertService.singleButtonAlertDialog(
                            "Please enter a valid amount",
                            true,
                            context,
                            () => Navigator.pop(context),
                          );
                        } else {
                          bool isEdit = transactionDetails.merchant.isNotEmpty;
                          showLoading(context);
                          transactionDetails.amount = double.parse(txnAmount);
                          transactionDetails.category = txnCategory;
                          transactionDetails.date = DateFormat(
                            "yyyy-MM-dd",
                          ).format(dateFormat.parse(txnDate));
                          transactionDetails.merchant = txnMerchant;
                          if (await transactionService.addTransaction(
                            transactionDetails,
                          )) {
                            Navigator.pop(context);
                            AlertService.singleButtonAlertDialog(
                              "Transaction ${isEdit ? "Updated" : "Added"} Successfully",
                              false,
                              context,
                              () {
                                Navigator.pop(context);
                                if (isEdit) {
                                  Navigator.popUntil(
                                    context,
                                    ModalRoute.withName('/home'),
                                  );
                                }
                              },
                            );
                            addedTxns.add(
                              TblTransactions.clone(transactionDetails),
                            );
                          } else {
                            Navigator.pop(context);
                            AlertService.singleButtonAlertDialog(
                              "Error while ${isEdit ? "updating" : "adding"} transaction. Try again",
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
                        transactionDetails.merchant.isEmpty ? "ADD" : "UPDATE",
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
