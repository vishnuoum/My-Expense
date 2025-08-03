import 'package:my_expense/models/bar_data.dart';
import 'package:my_expense/models/bar_graph_data.dart';
import 'package:my_expense/models/cash_card_analytics_details.dart';
import 'package:my_expense/models/category_analytics_details.dart';
import 'package:my_expense/models/response.dart';
import 'package:my_expense/services/db_service.dart';

class AnalyticsService {
  DBService dbService;

  AnalyticsService({required this.dbService});

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

  Future<Response> getSelectedMonthCashCardAnalytics({
    required int month,
    required int year,
  }) async {
    Response response = await dbService.getSelectedMonthCashCardAnalytics(
      month: month,
      year: year,
    );
    if (response.isException) return response;
    List<CashCardAnalyticsDetails> details = response.responseBody;
    return Response.success(
      responseBody: BarGraphData(
        barData: details
            .map(
              (element) => BarData(
                x: element.date,
                cardTotal: element.cardTotal,
                cashTotal: element.cashTotal,
              ),
            )
            .toList(),
        xLabels: details.map((element) => element.date).toList(),
      ),
    );
  }

  Future<Response> getSelectedYearCashCardAnalytics({required int year}) async {
    Response response = await dbService.getSelectedYearCashCardAnalytics(
      year: year,
    );
    if (response.isException) return response;
    List<CashCardAnalyticsDetails> details = response.responseBody;
    return Response.success(
      responseBody: BarGraphData(
        barData: details
            .map(
              (element) => BarData(
                x: monthList[int.parse(element.date)],
                cardTotal: element.cardTotal,
                cashTotal: element.cashTotal,
              ),
            )
            .toList(),
        xLabels: details.map((element) => element.date).toList(),
      ),
    );
  }

  Future<Response> getSelectedMonthCategoryAnalytics({
    required int month,
    required int year,
    required String txnType,
  }) async {
    return await dbService.getSelectedMonthCategoryAnalytics(
      month: month,
      year: year,
      txnType: txnType,
    );
  }
}
