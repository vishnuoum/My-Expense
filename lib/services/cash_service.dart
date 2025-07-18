import 'dart:developer';

import 'package:my_expense/entity/tbl_transaction.dart';
import 'package:my_expense/models/cash_details.dart';
import 'package:my_expense/models/response.dart';
import 'package:my_expense/services/db_service.dart';

class CashService {
  DBService dbService;

  CashService({required this.dbService});

  Future<Response> getCashDetails() async {
    Response response = await dbService.getRecentCashTxns();
    if (response.isException) return response;

    List<TblTransactions> cashTransactions = response.responseBody;
    log("getCashDetails $cashTransactions");
    CashDetails cashDetails = CashDetails(transactions: cashTransactions);

    double income = 0;
    double spends = 0;

    for (TblTransactions txn in cashTransactions) {
      if (txn.isCredit == 1) {
        income += txn.amount;
      } else {
        spends += txn.amount;
      }
    }
    cashDetails.recentIncomes = income;
    cashDetails.recentSpents = spends;

    Response balanceResponse = await dbService.getCurrentCashBalance();
    if (!balanceResponse.isException) {
      cashDetails.currentBalance = balanceResponse.responseBody;
    }

    return Response.success(responseBody: cashDetails);
  }
}
