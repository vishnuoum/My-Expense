class TblCards {
  int? id;
  String cardNo;
  String cardName;
  String cardLimit;
  int billDay;

  TblCards({
    this.id,
    required this.cardNo,
    required this.cardName,
    required this.cardLimit,
    required this.billDay,
  });

  Map<String, dynamic> getMap() {
    Map<String, dynamic> map = {
      "id": id,
      "cardNo": cardNo,
      "cardName": cardName,
      "cardLimit": cardLimit,
      "billDay": billDay,
    };

    if (null != id) {}
    return map;
  }

  @override
  String toString() {
    return """{
      "id": $id,
      "cardNo": $cardNo,
      "cardName":$cardName,
      "cardLimit": $cardLimit,
      "billDay": $billDay
    }""";
  }

  factory TblCards.fromMap(Map<String, dynamic> map) {
    return TblCards(
      id: map["id"],
      cardNo: map["cardNo"],
      cardName: map["cardName"],
      cardLimit: map["cardLimit"],
      billDay: map["billDay"],
    );
  }
}
