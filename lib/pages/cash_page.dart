import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:my_expense/models/Transaction.dart';

class CashPage extends StatefulWidget {
  const CashPage({super.key});

  @override
  State<CashPage> createState() => _CashPageState();
}

class _CashPageState extends State<CashPage> {
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
            SizedBox(height: 40),
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
                  Text(
                    "Rs. 25000.00",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 45),
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
                                    "Rs. 15000",
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
                                    "Rs. 15000",
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
