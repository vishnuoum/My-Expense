import 'dart:developer';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:my_expense/main.dart';
import 'package:my_expense/models/Transaction.dart';
import 'package:my_expense/services/card_service.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  CardService cardService = CardService(dbService: dbService);

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    log("fetching card details");
    await cardService.getAllCardDetails();
  }

  Widget getCard() {
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
                  "HDFC Millennia Credit",
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
                      PopupMenuItem<Widget>(child: Text('Edit')),
                      PopupMenuItem<Widget>(child: Text('Remove')),
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
                        "Rs. 16,000.00",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Total Amount",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Rs. 1,44,000.00",
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
                        "22/02/2025",
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
                        PieChart(getPieChart()),
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

  PieChartData getPieChart() {
    return PieChartData(
      sectionsSpace: 5,
      centerSpaceRadius: 45,
      startDegreeOffset: -90,
      sections: [
        PieChartSectionData(
          color: Colors.grey,
          value: 84,
          title: '84%',
          showTitle: true,
          radius: 30,
          titleStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        PieChartSectionData(
          color: Colors.black,
          value: 5,
          title: '5%',
          showTitle: false,
          radius: 30,
          titleStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Transaction> transactions = [
    Transaction("20/12/2024", "1200.00", false, "Amazon", "Shopping"),
    Transaction("20/12/2024", "1200.00", false, "Amazon", "Shopping"),
    Transaction("20/12/2024", "1200.00", false, "Amazon", "Shopping"),
    Transaction("20/12/2024", "1200.00", true, "Bill Payment", "Settlement"),
    Transaction("20/12/2024", "1200.00", false, "Amazon", "Shopping"),
    Transaction("20/12/2024", "1200.00", false, "Amazon", "Shopping"),
    Transaction("20/12/2024", "1200.00", false, "Amazon", "Shopping"),
    Transaction("20/12/2024", "1200.00", true, "Bill Payment", "Settlement"),
  ];

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController();
    return Scaffold(
      // appBar: AppBar(
      //   actions: [
      //     IconButton(onPressed: () {}, icon: Icon(Icons.more_vert_outlined)),
      //   ],
      // ),
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
                    await Navigator.pushNamed(context, "/addCard");
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
              child: LayoutBuilder(
                builder: (context, constraints) => PageView.builder(
                  controller: pageController,
                  scrollDirection: Axis.horizontal,
                  itemCount: 2,
                  itemBuilder: (context, index) => getCard(),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: SmoothPageIndicator(
                controller: pageController,
                count: 2,
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
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {},
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
                          "Rs.${transactions[index].amount}",
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
                          (45 + (transactions[index].isCredit ? 180 : 0)) *
                          math.pi /
                          180,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: transactions[index].isCredit
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
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
