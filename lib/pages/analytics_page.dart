import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_expense/main.dart';
import 'package:my_expense/models/bar_data.dart';
import 'package:my_expense/models/bar_graph_data.dart';
import 'package:my_expense/models/category_analytics_details.dart';
import 'package:my_expense/models/response.dart';
import 'package:my_expense/services/analytics_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  DateFormat calendarDateFormat = DateFormat("yyyy-MM-dd");

  dynamic monthlyBarGraph;
  dynamic yearlyBarGraph;
  dynamic catCardGraph;
  dynamic catCashGraph;
  bool isMonthlyBarLoading = true;
  bool isYearlyBarLoading = true;
  bool isCatCardLoading = true;
  bool isCatCashLoading = true;

  DateTime now = DateTime.now();
  int monthlyBarMonth = int.parse(DateFormat("MM").format(DateTime.now()));
  int monthlyBarYear = DateTime.now().year;
  int yearlyBarYear = DateTime.now().year;

  int monthlyCategoryCardMonth = int.parse(
    DateFormat("MM").format(DateTime.now()),
  );
  int monthlyCategoryCardYear = DateTime.now().year;
  int monthlyCategoryCashMonth = int.parse(
    DateFormat("MM").format(DateTime.now()),
  );
  int monthlyCategoryCashYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    fetchFromDB();
  }

  dynamic getBarChart({
    required String xLabel,
    required String yLabel,
    required List<BarData> data,
  }) {
    try {
      return SfCartesianChart(
        zoomPanBehavior: ZoomPanBehavior(
          enablePanning: true,
          enableDoubleTapZooming: true,
          enablePinching: true,
        ),
        primaryXAxis: CategoryAxis(
          // title: AxisTitle(
          //   text: xLabel,
          //   textStyle: TextStyle(fontWeight: FontWeight.bold),
          // ),
          majorGridLines: const MajorGridLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          // title: AxisTitle(
          //   text: yLabel,
          //   textStyle: TextStyle(fontWeight: FontWeight.bold),
          // ),
          majorGridLines: const MajorGridLines(width: 0),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          format: "point.x : ₹point.y",
        ),
        legend: Legend(isVisible: true, alignment: ChartAlignment.far),
        series: <CartesianSeries>[
          ColumnSeries<BarData, String>(
            name: 'Card',
            dataSource: data,
            xValueMapper: (BarData item, _) => item.x,
            yValueMapper: (BarData item, _) => item.cardTotal,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          ColumnSeries<BarData, String>(
            name: 'Cash',
            dataSource: data,
            xValueMapper: (BarData item, _) => item.x,
            yValueMapper: (BarData item, _) => item.cashTotal,
            color: Colors.grey,
          ),
        ],
      );
    } catch (error) {
      log("Error while building bar graph");
    }
  }

  void fetchFromDB() {
    fetchMonthlyBarGraphDetailsFromDB(
      month: monthlyBarMonth,
      year: monthlyBarYear,
    );
    fetchYearlyBarGraphDetailsFromDB(year: yearlyBarYear);
    fetchMonthlyCategoryCard(
      month: monthlyCategoryCardMonth,
      year: monthlyCategoryCardYear,
    );
    fetchMonthlyCategoryCash(
      month: monthlyCategoryCardMonth,
      year: monthlyCategoryCardYear,
    );
  }

  Future<void> fetchMonthlyBarGraphDetailsFromDB({
    required int month,
    required int year,
  }) async {
    setState(() {
      isMonthlyBarLoading = true;
      monthlyBarGraph = null;
    });
    Response response = await analyticsService
        .getSelectedMonthCashCardAnalytics(month: month, year: year);
    if (!response.isException) {
      BarGraphData data = response.responseBody;
      monthlyBarGraph = getBarChart(
        xLabel: "Dates",
        yLabel: "Amount",
        data: data.barData,
      );
    }
    setState(() {
      isMonthlyBarLoading = false;
    });
  }

  Future<void> fetchYearlyBarGraphDetailsFromDB({required int year}) async {
    setState(() {
      isYearlyBarLoading = true;
      yearlyBarGraph = null;
    });
    Response response = await analyticsService.getSelectedYearCashCardAnalytics(
      year: year,
    );
    if (!response.isException) {
      BarGraphData data = response.responseBody;
      yearlyBarGraph = getBarChart(
        xLabel: "Dates",
        yLabel: "Amount",
        data: data.barData,
      );
    }
    setState(() {
      isYearlyBarLoading = false;
    });
  }

  Future<void> fetchMonthlyCategoryCard({
    required int month,
    required int year,
  }) async {
    setState(() {
      isCatCardLoading = true;
      catCardGraph = null;
    });

    Response response = await analyticsService
        .getSelectedMonthCategoryAnalytics(
          year: year,
          month: month,
          txnType: "card",
        );
    if (!response.isException) {
      log("$response");
      catCardGraph = getCategoryChart(response.responseBody);
    }
    setState(() {
      isCatCardLoading = false;
    });
  }

  Future<void> fetchMonthlyCategoryCash({
    required int month,
    required int year,
  }) async {
    setState(() {
      isCatCashLoading = true;
      catCashGraph = null;
    });

    Response response = await analyticsService
        .getSelectedMonthCategoryAnalytics(
          year: year,
          month: month,
          txnType: "cash",
        );
    if (!response.isException) {
      log("$response");
      catCashGraph = getCategoryChart(response.responseBody);
    }
    setState(() {
      isCatCashLoading = false;
    });
  }

  Widget getCategoryChart(List<CategoryAnalyticsDetails> details) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white),
      child: details.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  "No data to be shown",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          : ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(10),
              shrinkWrap: true,
              itemCount: details.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              details[index].category,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            LinearProgressIndicator(
                              value: details[index].percentage,
                              color: Colors.black,
                              backgroundColor: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Rs.${details[index].totalSpent}",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${(details[index].percentage * 100).toStringAsFixed(2)}%",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget getDropDown({
    required List<Map<dynamic, dynamic>> dataMap,
    required Function function,
    required dynamic value,
  }) {
    return ButtonTheme(
      alignedDropdown: true,
      child: DropdownButton<dynamic>(
        value: value,
        isExpanded: true,
        hint: const Text('Select month'),
        icon: const Icon(Icons.arrow_drop_down),
        onChanged: (dynamic newValue) {
          function(newValue);
        },
        underline: SizedBox.shrink(),
        items: dataMap.map((Map<dynamic, dynamic> data) {
          return DropdownMenuItem<dynamic>(
            value: data["value"],
            child: Text(data["label"]),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: 30),
            Text(
              "Analytics",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: 10),
                children: [
                  Row(
                    children: [
                      Text(
                        "Monthly Spents",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(child: SizedBox()),
                      SizedBox(
                        width: 80,
                        child: getDropDown(
                          dataMap: AnalyticsService.monthList
                              .sublist(1)
                              .asMap()
                              .entries
                              .map(
                                (entry) => {
                                  "label": entry.value,
                                  "value": entry.key + 1,
                                },
                              )
                              .toList(),
                          function: (dynamic value) {
                            if (value != null) {
                              log("New Month Selected $value");
                              setState(() {
                                monthlyBarMonth = value;
                              });
                              fetchMonthlyBarGraphDetailsFromDB(
                                month: monthlyBarMonth,
                                year: monthlyBarYear,
                              );
                            }
                          },
                          value: monthlyBarMonth,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: getDropDown(
                          dataMap:
                              List.generate(
                                    now.year - 2000 + 1,
                                    (index) => 2000 + index,
                                  ).reversed
                                  .map(
                                    (value) => {
                                      "label": value.toString(),
                                      "value": value,
                                    },
                                  )
                                  .toList(),
                          function: (dynamic value) {
                            if (value != null) {
                              log("New Year Selected $value");
                              setState(() {
                                monthlyBarYear = value;
                              });
                              fetchMonthlyBarGraphDetailsFromDB(
                                month: monthlyBarMonth,
                                year: monthlyBarYear,
                              );
                            }
                          },
                          value: monthlyBarYear,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 250,
                    child: isMonthlyBarLoading
                        ? Center(child: CircularProgressIndicator())
                        : monthlyBarGraph ??
                              Center(
                                child: Text(
                                  "No data to be shown",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        "Yearly Spents",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(child: SizedBox()),
                      SizedBox(
                        width: 100,
                        child: getDropDown(
                          dataMap:
                              List.generate(
                                    now.year - 2000 + 1,
                                    (index) => 2000 + index,
                                  ).reversed
                                  .map(
                                    (value) => {
                                      "label": value.toString(),
                                      "value": value,
                                    },
                                  )
                                  .toList(),
                          function: (dynamic value) {
                            if (value != null) {
                              log("New Year Selected $value");
                              setState(() {
                                yearlyBarYear = value;
                              });
                              fetchYearlyBarGraphDetailsFromDB(
                                year: yearlyBarYear,
                              );
                            }
                          },
                          value: yearlyBarYear,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 250,
                    child: isYearlyBarLoading
                        ? Center(child: CircularProgressIndicator())
                        : yearlyBarGraph ??
                              Center(
                                child: Text(
                                  "No data to be shown",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        "Card Category",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(child: SizedBox()),
                      SizedBox(
                        width: 80,
                        child: getDropDown(
                          dataMap: AnalyticsService.monthList
                              .sublist(1)
                              .asMap()
                              .entries
                              .map(
                                (entry) => {
                                  "label": entry.value,
                                  "value": entry.key + 1,
                                },
                              )
                              .toList(),
                          function: (dynamic value) {
                            if (value != null) {
                              log("New Month Selected $value");
                              setState(() {
                                monthlyCategoryCardMonth = value;
                              });
                              fetchMonthlyCategoryCard(
                                month: monthlyCategoryCardMonth,
                                year: monthlyCategoryCardYear,
                              );
                            }
                          },
                          value: monthlyCategoryCardMonth,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: getDropDown(
                          dataMap:
                              List.generate(
                                    now.year - 2000 + 1,
                                    (index) => 2000 + index,
                                  ).reversed
                                  .map(
                                    (value) => {
                                      "label": value.toString(),
                                      "value": value,
                                    },
                                  )
                                  .toList(),
                          function: (dynamic value) {
                            if (value != null) {
                              log("New Year Selected $value");
                              setState(() {
                                monthlyCategoryCardYear = value;
                              });
                              fetchMonthlyCategoryCard(
                                month: monthlyCategoryCardMonth,
                                year: monthlyCategoryCardYear,
                              );
                            }
                          },
                          value: monthlyCategoryCardYear,
                        ),
                      ),
                    ],
                  ),
                  isCatCardLoading
                      ? Center(child: CircularProgressIndicator())
                      : catCardGraph ??
                            Center(
                              child: Text(
                                "No data to be shown",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        "Cash Category",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(child: SizedBox()),
                      SizedBox(
                        width: 80,
                        child: getDropDown(
                          dataMap: AnalyticsService.monthList
                              .sublist(1)
                              .asMap()
                              .entries
                              .map(
                                (entry) => {
                                  "label": entry.value,
                                  "value": entry.key + 1,
                                },
                              )
                              .toList(),
                          function: (dynamic value) {
                            if (value != null) {
                              log("New Month Selected $value");
                              setState(() {
                                monthlyCategoryCashMonth = value;
                              });
                              fetchMonthlyCategoryCash(
                                month: monthlyCategoryCashMonth,
                                year: monthlyCategoryCashYear,
                              );
                            }
                          },
                          value: monthlyCategoryCashMonth,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: getDropDown(
                          dataMap:
                              List.generate(
                                    now.year - 2000 + 1,
                                    (index) => 2000 + index,
                                  ).reversed
                                  .map(
                                    (value) => {
                                      "label": value.toString(),
                                      "value": value,
                                    },
                                  )
                                  .toList(),
                          function: (dynamic value) {
                            if (value != null) {
                              log("New Year Selected $value");
                              setState(() {
                                monthlyCategoryCashYear = value;
                              });
                              fetchMonthlyCategoryCash(
                                month: monthlyCategoryCashMonth,
                                year: monthlyCategoryCashYear,
                              );
                            }
                          },
                          value: monthlyCategoryCashYear,
                        ),
                      ),
                    ],
                  ),
                  isCatCashLoading
                      ? Center(child: CircularProgressIndicator())
                      : catCashGraph ??
                            Center(
                              child: Text(
                                "No data to be shown",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
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

// To-do
// category wise analysis, card vs cash spends, Month wise spends, income vs spent in cash
