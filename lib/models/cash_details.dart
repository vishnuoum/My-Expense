import 'package:my_expense/entity/tbl_transaction.dart';

class CashDetails {
  double currentBalance;
  double recentSpents;
  double recentIncomes;
  List<TblTransactions> transactions;

  CashDetails({
    this.currentBalance = 0,
    this.recentSpents = 0,
    this.recentIncomes = 0,
    this.transactions = const <TblTransactions>[],
  });
}
