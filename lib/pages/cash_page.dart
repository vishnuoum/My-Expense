import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my_expense/entity/tbl_transaction.dart';
import 'package:my_expense/main.dart';
import 'package:my_expense/models/cash_details.dart';
import 'package:my_expense/models/response.dart';
import 'package:my_expense/services/alert_service.dart';

class CashPage extends StatefulWidget {
  const CashPage({super.key});

  @override
  State<CashPage> createState() => _CashPageState();
}

class _CashPageState extends State<CashPage> {
  bool isFabVisible = true;
  ScrollController scrollController = ScrollController();
  CashDetails cashDetails = CashDetails();

  @override
  void initState() {
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        // scrolling down
        if (isFabVisible) {
          setState(() => isFabVisible = false);
        }
      } else if (scrollController.position.userScrollDirection ==
              ScrollDirection.forward ||
          scrollController.position.atEdge && scrollController.offset == 0) {
        // scrolling up or at the top
        if (!isFabVisible) {
          setState(() => isFabVisible = true);
        }
      }
    });
    init();
    super.initState();
  }

  Future<void> init() async {
    Response response = await cashService.getCashDetails();
    if (!response.isException) {
      setState(() {
        cashDetails = response.responseBody;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   actions: [
      //     IconButton(onPressed: () {}, icon: Icon(Icons.more_vert_outlined)),
      //   ],
      // ),
      floatingActionButton: AnimatedSlide(
        duration: Duration(milliseconds: 200),
        offset: isFabVisible ? Offset.zero : Offset(0, 2),
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 200),
          opacity: isFabVisible ? 1.0 : 0.0,
          child: FloatingActionButton.extended(
            heroTag: "Cash FAB",
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                "/addTxn",
                arguments: TblTransactions.headerInfo(
                  uniqueId: "",
                  txnType: "cash",
                ),
              );
              init();
            },
            tooltip: "Add Transaction",
            icon: Icon(Icons.add),
            label: Text("Add Transaction"),
          ),
        ),
      ),
      body: SafeArea(
        minimum: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Cash",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 40),
            SizedBox(
              height: 213,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Current Balance",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // SizedBox(height: 10),
                  GestureDetector(
                    onDoubleTap: () async {
                      log("Double tapped current balance");
                      await smsService.syncFromSharedPreference();
                      await init();
                    },
                    child: Text(
                      "Rs.${cashDetails.currentBalance}",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 45,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 5,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Recent Spents",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Rs.${cashDetails.recentSpents}",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Card(
                            elevation: 5,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Recent Incomes",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Rs.${cashDetails.recentIncomes}",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Recent Transactions",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: cashDetails.transactions.isEmpty
                  ? Center(
                      child: Text(
                        "No recent transactions",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      shrinkWrap: true,
                      itemCount: cashDetails.transactions.length,
                      itemBuilder: (context, index) {
                        return ExpansionTile(
                          title: Text(
                            cashDetails.transactions[index].merchant,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            cashDetails.transactions[index].category,
                            style: TextStyle(color: Colors.grey),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Rs.${cashDetails.transactions[index].amount}",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(cashDetails.transactions[index].date),
                            ],
                          ),
                          leading: Transform.rotate(
                            angle:
                                (45 +
                                    (cashDetails.transactions[index].isCredit ==
                                            1
                                        ? 180
                                        : 0)) *
                                math.pi /
                                180,
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color:
                                  cashDetails.transactions[index].isCredit == 1
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
                                    double amount =
                                        cashDetails.transactions[index].amount;
                                    await Navigator.pushNamed(
                                      context,
                                      "/addTxn",
                                      arguments:
                                          cashDetails.transactions[index],
                                    );
                                    setState(() {
                                      cashDetails.currentBalance +=
                                          (amount -
                                          cashDetails
                                              .transactions[index]
                                              .amount);
                                    });
                                    if (cashDetails
                                            .transactions[index]
                                            .isCredit ==
                                        1) {
                                      cashDetails.recentIncomes +=
                                          (cashDetails
                                              .transactions[index]
                                              .amount -
                                          amount);
                                    } else {
                                      cashDetails.recentSpents +=
                                          (cashDetails
                                              .transactions[index]
                                              .amount -
                                          amount);
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      Icon(Icons.edit, size: 22),
                                      SizedBox(height: 2),
                                      Text(
                                        "Edit",
                                        style: TextStyle(fontSize: 15),
                                      ),
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
                                          cashDetails.transactions[index].id
                                              as int,
                                        )) {
                                          AlertService.singleButtonAlertDialog(
                                            "Successfully deleted the transaction",
                                            true,
                                            context,
                                            () => navigator.pop(context),
                                          );
                                          if (cashDetails
                                                  .transactions[index]
                                                  .isCredit ==
                                              1) {
                                            cashDetails.currentBalance -=
                                                cashDetails
                                                    .transactions[index]
                                                    .amount;
                                            cashDetails.recentIncomes -=
                                                cashDetails
                                                    .transactions[index]
                                                    .amount;
                                          } else {
                                            cashDetails.currentBalance +=
                                                cashDetails
                                                    .transactions[index]
                                                    .amount;
                                            cashDetails.recentSpents -=
                                                cashDetails
                                                    .transactions[index]
                                                    .amount;
                                          }
                                          setState(() {
                                            cashDetails.transactions.removeAt(
                                              index,
                                            );
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
                                      Text(
                                        "Delete",
                                        style: TextStyle(fontSize: 15),
                                      ),
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
            ),
          ],
        ),
      ),
    );
  }
}
