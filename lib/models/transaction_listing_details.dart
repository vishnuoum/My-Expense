class TransactionListingDetails {
  String header;
  String uniqueId;
  String txnType;
  late String from;
  late String to;

  TransactionListingDetails({
    required this.header,
    required this.uniqueId,
    required this.txnType,
  });
}
