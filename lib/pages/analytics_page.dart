import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_expense/main.dart';
import 'package:my_expense/models/bar_data.dart';
import 'package:my_expense/models/bar_graph_data.dart';
import 'package:my_expense/models/response.dart';
import 'package:my_expense/services/alert_service.dart';
import 'package:my_expense/theme_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String fromDate = "";
  String toDate = "";
  DateFormat calendarDateFormat = DateFormat("yyyy-MM-dd");

  int activeSelector = 0;

  dynamic barGraph;
  dynamic catGraph;
  bool isBarLoading = true;
  bool isCatLoading = true;

  static final List<String> monthList = [
    "",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  List<String> seletorTitles = ["This Month", "This Year", "Monthly", "Yearly"];

  @override
  void initState() {
    DateTime now = DateTime.now();
    fromDate = calendarDateFormat.format(DateTime(now.year, now.month, 1));
    toDate = calendarDateFormat.format(now);
    super.initState();
    fetchFromDB(activeSelector);
  }

  Widget getSelector(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          activeSelector = index;
        });
        fetchFromDB(index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: activeSelector == index
              ? Theme.of(context).appBarTheme.foregroundColor
              : themeController.value == ThemeMode.dark
              ? Colors.grey[800]
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: activeSelector == index
                  ? Theme.of(context).appBarTheme.backgroundColor
                  : Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
        ),
      ),
    );
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

  void fetchFromDB(int index) {
    fetchBarGraphDetailsFromDB(index);
  }

  Future<void> fetchBarGraphDetailsFromDB(int index) async {
    switch (index) {
      case 0:
        setState(() {
          isBarLoading = true;
        });
        Response response = await analyticsService
            .getCurrentMonthCashCardAnalytics();
        if (!response.isException) {
          BarGraphData data = response.responseBody;
          barGraph = getBarChart(
            xLabel: "Dates",
            yLabel: "Amount",
            data: data.barData,
          );
        }
        setState(() {
          isBarLoading = false;
        });
        break;
      case 1:
        setState(() {
          isBarLoading = true;
          barGraph = null;
        });
        break;
      case 2:
        setState(() {
          isBarLoading = true;
          barGraph = null;
        });
        break;
      case 3:
        setState(() {
          isBarLoading = true;
          barGraph = null;
        });
        break;
    }
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
            SizedBox(
              height: 70,
              child: ListView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(10),
                scrollDirection: Axis.horizontal,
                children: seletorTitles.asMap().entries.map((entry) {
                  return getSelector(entry.value, entry.key);
                }).toList(),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: 10),
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Card vs Cash Spents",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 250,
                    child: isBarLoading
                        ? Center(child: CircularProgressIndicator())
                        : barGraph ??
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
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Category Analytics",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 250,
                    child: isCatLoading
                        ? Center(child: CircularProgressIndicator())
                        : catGraph ??
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
