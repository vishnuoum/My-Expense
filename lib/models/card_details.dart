import 'package:my_expense/entity/tbl_transaction.dart';

class CardDetails {
  int id;
  String cardName;
  String cardLimit;
  double currentAmount;
  String nextBillDate;
  int daysToNextBill;
  late List<TblTransactions> txns;

  CardDetails({
    required this.id,
    required this.cardName,
    required this.cardLimit,
    required this.currentAmount,
    required this.nextBillDate,
    required this.daysToNextBill,
  });
}
