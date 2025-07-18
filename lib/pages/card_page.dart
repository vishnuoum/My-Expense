import 'dart:developer';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my_expense/entity/tbl_transaction.dart';
import 'package:my_expense/main.dart';
import 'package:my_expense/models/card_details.dart';
import 'package:my_expense/models/response.dart';
import 'package:my_expense/scroll_behavior/stretch_scroll_behavior.dart';
import 'package:my_expense/services/alert_service.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  ScrollController scrollController = ScrollController();
  PageController pageController = PageController();
  List<CardDetails> cardDetailsList = [];
  List<TblTransactions> txnList = [];
  bool isFabVisible = false;

  Map<String, double> scrollOffset = {};

  int txnListIndex = 0;

  @override
  void initState() {
    pageController.addListener(() {
      if (pageController.page?.remainder(1) == 0) {
        int page = pageController.page?.toInt() as int;
        if (txnListIndex != page) {
          if (scrollController.hasClients) {
            scrollOffset[cardDetailsList[txnListIndex].cardNum] =
                scrollController.offset;
          }
          txnListIndex = page;
          log("current card index: $txnListIndex");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollController.hasClients) {
              scrollController.animateTo(
                scrollOffset[cardDetailsList[txnListIndex].cardNum] ?? 0,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          });
          setState(() {
            txnList = cardDetailsList[txnListIndex].txns;
          });
        }
      }
    });

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

  void init() async {
    log("fetching card details ${DateTime.now()}");
    Response cardDetailsResponse = await cardService.getAllCardDetails();
    if (cardDetailsResponse.isException) {
      AlertService.singleButtonAlertDialog(
        "Error while getching card details",
        true,
        context,
        () {
          Navigator.pop(context);
        },
      );
    } else {
      cardDetailsList = (cardDetailsResponse.responseBody as List<CardDetails>);
      cardDetailsList.forEach(
        (card) => scrollOffset.putIfAbsent(card.cardNum, () => 0),
      );
      setState(() {
        if (cardDetailsList.isNotEmpty &&
            txnListIndex < cardDetailsList.length) {
          txnList = cardDetailsList[txnListIndex].txns;
          if (scrollController.hasClients) {
            scrollController.jumpTo(
              scrollOffset[cardDetailsList[txnListIndex].cardNum] ?? 0,
            );
          }
        }
        isFabVisible = cardDetailsList.isNotEmpty;
      });
    }
  }

  Widget getCard(CardDetails cardDetails) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${cardDetails.cardName} (*${cardDetails.cardNum})",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                PopupMenuButton(
                  child: Icon(Icons.more_vert, color: Colors.black),
                  itemBuilder: (BuildContext context) {
                    // Define the menu items in a function
                    return <PopupMenuEntry<Widget>>[
                      // Add PopupMenuItem or PopupMenuItemBuilder entries here
                      PopupMenuItem<Widget>(
                        child: Text('Edit'),
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            "/addCard",
                            arguments: cardDetailsList[txnListIndex],
                          );
                          setState(() {});
                        },
                      ),
                      PopupMenuItem<Widget>(
                        child: Text('Remove'),
                        onTap: () {
                          AlertService.twoButtonAlertDialog(
                            "Are you sure, you want to delete the card?",
                            true,
                            context,
                            "Yes",
                            () async {
                              Navigator.pop(context);
                              final navigator = Navigator.of(context);
                              if (await dbService.deleteCard(
                                cardDetailsList[txnListIndex].id,
                              )) {
                                AlertService.singleButtonAlertDialog(
                                  "Successfully deleted the card",
                                  true,
                                  context,
                                  () => navigator.pop(context),
                                );
                                cardDetailsList.removeAt(txnListIndex);
                                txnListIndex = 0;
                                if (cardDetailsList.isNotEmpty) {
                                  setState(() {
                                    txnList =
                                        cardDetailsList[txnListIndex].txns;
                                  });
                                }
                              } else {
                                AlertService.singleButtonAlertDialog(
                                  "Error while deleteing card",
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
                      ),
                      // ... add more menu items
                    ];
                  },
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Current Amount",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Rs.${cardDetails.currentAmount.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Total Limit",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Rs.${cardDetails.cardLimit.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Bill Date",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "${cardDetails.nextBillDate} (${cardDetails.daysToNextBill} days left)",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: SizedBox(
                    height: 140,
                    width: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(getPieChart(cardDetails.creditUsage)),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Current",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "Usage",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PieChartData getPieChart(double usage) {
    return PieChartData(
      sectionsSpace: 5,
      centerSpaceRadius: 45,
      startDegreeOffset: -90,
      sections: [
        PieChartSectionData(
          color: Colors.grey,
          value: 100 - usage,
          title: '${(100 - usage).toStringAsFixed(1)}%',
          showTitle: usage < 90,
          radius: 30,
          titleStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 9,
          ),
        ),
        PieChartSectionData(
          color: Colors.black,
          value: usage,
          title: '${usage.toStringAsFixed(1)}%',
          showTitle: usage > 10,
          radius: 30,
          titleStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AnimatedSlide(
        duration: Duration(milliseconds: 200),
        offset: isFabVisible ? Offset.zero : Offset(0, 2),
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 200),
          opacity: isFabVisible ? 1.0 : 0.0,
          child: FloatingActionButton.extended(
            heroTag: "Card FAB",
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                "/addTxn",
                arguments: TblTransactions.headerInfo(
                  uniqueId: cardDetailsList[txnListIndex].cardNum,
                  txnType: "card",
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Cards",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      "/addCard",
                      arguments: CardDetails(
                        id: -1,
                        cardNum: "",
                        cardName: "",
                        cardLimit: 0,
                        billDay: 0,
                        currentAmount: 0,
                        nextBillDate: "",
                        daysToNextBill: 0,
                      ),
                    );
                    if (null != result && result is CardDetails) {
                      CardDetails cardDetailsFromForm = result;
                      if (cardDetailsFromForm.cardNum.isNotEmpty) {
                        cardDetailsFromForm.txns = <TblTransactions>[];
                        setState(() {
                          cardDetailsList.add(cardDetailsFromForm);
                        });
                      }
                    }
                  },
                  child: Text(
                    "+",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 225,
              child: cardDetailsList.isEmpty
                  ? Card(
                      color: themeController.value == ThemeMode.dark
                          ? Colors.grey[900]
                          : Colors.grey[300],
                      child: Center(
                        child: Text(
                          "No cards to display",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) => PageView.builder(
                        scrollBehavior: StretchScrollBehavior(),
                        physics: ClampingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        controller: pageController,
                        scrollDirection: Axis.horizontal,
                        itemCount: cardDetailsList.length,
                        itemBuilder: (context, index) =>
                            getCard(cardDetailsList[index]),
                      ),
                    ),
            ),
            SizedBox(height: 10),
            Center(
              child: SmoothPageIndicator(
                controller: pageController,
                count: cardDetailsList.length,
                effect: WormEffect(
                  dotColor: const Color.fromARGB(255, 104, 104, 104),
                  activeDotColor: Theme.of(context).primaryColor,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
            ),
            SizedBox(height: 20),
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
              child: txnList.isEmpty
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
                      padding: EdgeInsets.only(bottom: 60),
                      shrinkWrap: true,
                      itemCount: txnList.length,
                      itemBuilder: (context, index) {
                        return ExpansionTile(
                          title: Text(
                            txnList[index].merchant,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            txnList[index].category,
                            style: TextStyle(color: Colors.grey),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Rs.${txnList[index].amount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(txnList[index].date),
                            ],
                          ),
                          leading: Transform.rotate(
                            angle:
                                (45 +
                                    (txnList[index].isCredit == 1 ? 180 : 0)) *
                                math.pi /
                                180,
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: txnList[index].isCredit == 1
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
                                    double amount = txnList[index].amount;
                                    await Navigator.pushNamed(
                                      context,
                                      "/addTxn",
                                      arguments: txnList[index],
                                    );
                                    cardDetailsList[txnListIndex].creditUsage =
                                        await cardService.getCreditUsage(
                                          cardDetailsList[txnListIndex].cardNum,
                                          cardDetailsList[txnListIndex]
                                              .cardLimit,
                                        );
                                    setState(() {
                                      cardDetailsList[txnListIndex]
                                              .currentAmount +=
                                          (txnList[index].amount - amount);
                                    });
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
                                  onTap: () {},
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
