class TblTransactions {
  int? id;
  double amount;
  String uniqueId;
  String txnType;
  int isCredit;
  String date;
  String merchant;
  String category;

  TblTransactions({
    this.id,
    required this.amount,
    required this.uniqueId,
    required this.txnType,
    required this.isCredit,
    required this.date,
    required this.merchant,
    required this.category,
  });

  TblTransactions.headerInfo({
    this.amount = 0,
    required this.uniqueId,
    required this.txnType,
    this.isCredit = 0,
    this.date = "",
    this.merchant = "",
    this.category = "",
  });

  Map<String, dynamic> getMap() {
    return {
      "id": id,
      "amount": amount,
      "uniqueId": uniqueId,
      "txnType": txnType,
      "isCredit": isCredit,
      "date": date,
      "merchant": merchant,
      "category": category,
    };
  }

  @override
  String toString() {
    return """{
      "id": $id,
      "amount": $amount,
      "uniqueId":$uniqueId,
      "txnType": $txnType,
      "isCredit", $isCredit,
      "date": $date,
      "merchant": $merchant,
      "category": $category
    }""";
  }

  factory TblTransactions.fromMap(Map<String, dynamic> map) {
    return TblTransactions(
      id: map["id"],
      amount: map["amount"],
      uniqueId: map["uniqueId"],
      txnType: map["txnType"],
      isCredit: map["isCredit"],
      date: map["date"],
      merchant: map["merchant"],
      category: map["category"],
    );
  }

  factory TblTransactions.clone(TblTransactions original) {
    return TblTransactions(
      id: original.id,
      amount: original.amount,
      uniqueId: original.uniqueId,
      txnType: original.txnType,
      isCredit: original.isCredit,
      date: original.date,
      merchant: original.merchant,
      category: original.category,
    );
  }
}
