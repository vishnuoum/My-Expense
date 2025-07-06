import 'package:my_expense/entity/tbl_transaction.dart';

class CardDetails {
  late int id;
  String cardNum;
  String cardName;
  double cardLimit;
  double currentAmount;
  String nextBillDate;
  int billDay;
  int daysToNextBill;
  double creditUsage;
  late List<TblTransactions> txns;

  CardDetails({
    required this.id,
    required this.cardNum,
    required this.cardName,
    required this.cardLimit,
    required this.currentAmount,
    required this.nextBillDate,
    required this.billDay,
    this.creditUsage = 0,
    required this.daysToNextBill,
  });
}
