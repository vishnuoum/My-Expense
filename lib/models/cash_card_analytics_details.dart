class CashCardAnalyticsDetails {
  String date;
  double cardTotal;
  double cashTotal;

  CashCardAnalyticsDetails({
    required this.date,
    required this.cardTotal,
    required this.cashTotal,
  });

  factory CashCardAnalyticsDetails.fromMap(Map<String, dynamic> map) {
    return CashCardAnalyticsDetails(
      date: map["date"],
      cardTotal: map["cardTotal"],
      cashTotal: map["cashTotal"],
    );
  }
}
