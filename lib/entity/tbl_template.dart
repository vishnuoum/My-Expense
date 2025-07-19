class TblTemplate {
  int? id;
  RegExp pattern;
  int amountGroup;
  int txnNatureGroup;
  int uniqueIdGroup;
  int merchantGroup;
  int dateGroup;

  TblTemplate({
    this.id,
    required this.pattern,
    required this.amountGroup,
    required this.txnNatureGroup,
    required this.uniqueIdGroup,
    required this.merchantGroup,
    required this.dateGroup,
  });

  factory TblTemplate.fromMap(Map<String, dynamic> map) {
    return TblTemplate(
      id: map["id"],
      pattern: RegExp(map["template"]),
      amountGroup: map["amountGroup"],
      txnNatureGroup: map["txnNatureGroup"],
      uniqueIdGroup: map["uniqueIdGroup"],
      merchantGroup: map["merchantGroup"],
      dateGroup: map["dateGroup"],
    );
  }
}
