import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_expense/entity/tbl_transaction.dart';
import 'package:my_expense/main.dart';
import 'package:my_expense/models/response.dart';
import 'package:my_expense/models/transaction_listing_details.dart';
import 'package:my_expense/services/alert_service.dart';

class AllTxnPage extends StatefulWidget {
  final TransactionListingDetails transactionDetails;
  const AllTxnPage({super.key, required this.transactionDetails});

  @override
  State<AllTxnPage> createState() => _AllTxnPageState();
}

class _AllTxnPageState extends State<AllTxnPage> {
  late TransactionListingDetails transactionDetails;

  DateFormat calendarDateFormat = DateFormat("yyyy-MM-dd");
  List<TblTransactions> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    transactionDetails = widget.transactionDetails;
    DateTime now = DateTime.now();
    transactionDetails.from = calendarDateFormat.format(
      DateTime(now.year, now.month, 1),
    );
    transactionDetails.to = calendarDateFormat.format(now);
    fetchFromDB();
    super.initState();
  }

  void fetchFromDB() async {
    setState(() {
      isLoading = true;
    });
    transactions.clear();
    Response dbResponse = await transactionService
        .getAllTransactionsWithinRange(transactionDetails);
    isLoading = false;
    if (dbResponse.isException) return;
    setState(() {
      transactions = dbResponse.responseBody as List<TblTransactions>;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).appBarTheme.backgroundColor,
        ),
        backgroundColor: Theme.of(context).appBarTheme.foregroundColor,
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              transactionDetails.header,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).appBarTheme.backgroundColor,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    DateTime? selectedDate = await AlertService.selectDate(
                      context,
                      calendarDateFormat.parse(transactionDetails.from),
                    );
                    if (null == selectedDate) return;
                    setState(() {
                      transactionDetails.from = calendarDateFormat.format(
                        selectedDate,
                      );
                    });
                    fetchFromDB();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "From",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).appBarTheme.backgroundColor,
                        ),
                      ),
                      Text(
                        transactionDetails.from,
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).appBarTheme.backgroundColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: Theme.of(context).appBarTheme.backgroundColor,
                ),
                GestureDetector(
                  onTap: () async {
                    DateTime? selectedDate = await AlertService.selectDate(
                      context,
                      calendarDateFormat.parse(transactionDetails.to),
                    );
                    if (null == selectedDate) return;
                    setState(() {
                      transactionDetails.to = calendarDateFormat.format(
                        selectedDate,
                      );
                    });
                    fetchFromDB();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "To",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).appBarTheme.backgroundColor,
                        ),
                      ),
                      Text(
                        transactionDetails.to,
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).appBarTheme.backgroundColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(strokeWidth: 5),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Loading",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : transactions.isEmpty
          ? Center(
              child: Text(
                "No transactions to display",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  title: Text(
                    transactions[index].merchant,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    transactions[index].category,
                    style: TextStyle(color: Colors.grey),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Rs.${transactions[index].amount.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(transactions[index].date),
                    ],
                  ),
                  leading: Transform.rotate(
                    angle:
                        (45 + (transactions[index].isCredit == 1 ? 180 : 0)) *
                        math.pi /
                        180,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: transactions[index].isCredit == 1
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),

                  children: [
                    SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              "/addTxn",
                              arguments: transactions[index],
                            );
                            if (result != null && result is TblTransactions) {
                              setState(() {
                                transactions[index] = result;
                              });
                            }
                          },
                          child: Column(
                            children: [
                              Icon(Icons.edit, size: 22),
                              SizedBox(height: 2),
                              Text("Edit", style: TextStyle(fontSize: 15)),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            AlertService.twoButtonAlertDialog(
                              "Are you sure, you want to delete the transaction?",
                              true,
                              context,
                              "Yes",
                              () async {
                                Navigator.pop(context);
                                final navigator = Navigator.of(context);
                                if (await transactionService.deleteTxn(
                                  transactions[index].id as int,
                                )) {
                                  AlertService.singleButtonAlertDialog(
                                    "Successfully deleted the transaction",
                                    true,
                                    context,
                                    () => navigator.pop(context),
                                  );
                                  setState(() {
                                    transactions.removeAt(index);
                                  });
                                } else {
                                  AlertService.singleButtonAlertDialog(
                                    "Error while deleteing transaction",
                                    true,
                                    context,
                                    () => Navigator.pop(context),
                                  );
                                }
                              },
                              "No",
                              () {
                                Navigator.pop(context);
                              },
                            );
                          },
                          child: Column(
                            children: [
                              Icon(Icons.delete, size: 22),
                              SizedBox(height: 2),
                              Text("Delete", style: TextStyle(fontSize: 15)),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }
}
