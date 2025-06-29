class Transaction {
  String date;
  String amount;
  bool isCredit;
  String merchant;
  String category;

  Transaction(
    this.date,
    this.amount,
    this.isCredit,
    this.merchant,
    this.category,
  );
}
