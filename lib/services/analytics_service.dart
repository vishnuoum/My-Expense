import 'package:my_expense/models/bar_data.dart';
import 'package:my_expense/models/bar_graph_data.dart';
import 'package:my_expense/models/cash_card_analytics_details.dart';
import 'package:my_expense/models/response.dart';
import 'package:my_expense/services/db_service.dart';

class AnalyticsService {
  DBService dbService;

  AnalyticsService({required this.dbService});

  Future<Response> getCurrentMonthCashCardAnalytics() async {
    Response response = await dbService.getCurrentMonthCashCardAnalytics();
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
}
