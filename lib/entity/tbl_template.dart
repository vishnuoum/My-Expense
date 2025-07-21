class TblTemplate {
  int? id;
  String patternName;
  RegExp pattern;
  int amountGroup;
  int uniqueIdGroup;
  int merchantGroup;
  int dateGroup;
  int isCredit;
  String txnType;
  String dateFormat;

  TblTemplate({
    this.id,
    required this.patternName,
    required this.pattern,
    required this.amountGroup,
    required this.uniqueIdGroup,
    required this.merchantGroup,
    required this.dateGroup,
    required this.isCredit,
    required this.txnType,
    required this.dateFormat,
  });

  factory TblTemplate.fromMap(Map<String, dynamic> map) {
    return TblTemplate(
      id: map["id"],
      patternName: map["patternName"],
      pattern: RegExp(map["pattern"]),
      amountGroup: map["amountGroup"],
      uniqueIdGroup: map["uniqueIdGroup"],
      merchantGroup: map["merchantGroup"],
      dateGroup: map["dateGroup"],
      isCredit: map["isCredit"],
      txnType: map["txnType"],
      dateFormat: map["dateFormat"],
    );
  }

  factory TblTemplate.empty() {
    return TblTemplate(
      patternName: "",
      pattern: RegExp(""),
      amountGroup: 0,
      uniqueIdGroup: 0,
      merchantGroup: 0,
      dateGroup: 0,
      isCredit: 0,
      txnType: "cash",
      dateFormat: "",
    );
  }

  factory TblTemplate.clone(TblTemplate template) {
    return TblTemplate(
      id: template.id,
      patternName: template.patternName,
      pattern: RegExp(template.pattern.pattern),
      amountGroup: template.amountGroup,
      uniqueIdGroup: template.uniqueIdGroup,
      merchantGroup: template.merchantGroup,
      dateGroup: template.dateGroup,
      isCredit: template.isCredit,
      txnType: template.txnType,
      dateFormat: template.dateFormat,
    );
  }

  Map<String, dynamic> getMap() {
    return {
      "id": id,
      "patternName": patternName,
      "amountGroup": amountGroup,
      "pattern": pattern.pattern,
      "uniqueIdGroup": uniqueIdGroup,
      "merchantGroup": merchantGroup,
      "dateGroup": dateGroup,
      "isCredit": isCredit,
      "txnType": txnType,
      "dateFormat": dateFormat,
    };
  }
}
