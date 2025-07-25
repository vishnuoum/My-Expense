import 'dart:math' as math;

import 'package:intl/intl.dart';
import 'package:my_expense/entity/tbl_card.dart';
import 'package:my_expense/entity/tbl_transaction.dart';
import 'package:my_expense/models/card_details.dart';
import 'package:my_expense/models/response.dart';
import 'package:my_expense/services/db_service.dart';

class CardService {
  DBService dbService;

  CardService({required this.dbService});

  Future<Response> addCard(TblCards card) async {
    return await dbService.addCard(card);
  }

  Future<Response> getAllCardDetails() async {
    Response cardResponse = await dbService.getAllCards();
    if (cardResponse.isException) return cardResponse;

    List<CardDetails> cardDetails = await Future.wait(
      (cardResponse.responseBody as List<TblCards>).map((card) async {
        DateTime nextBillDate = getNextBillDate(card.billDay);
        DateTime now = DateTime.now();
        return CardDetails(
          id: card.id!,
          cardNum: card.cardNo,
          cardName: card.cardName,
          cardLimit: card.cardLimit,
          currentAmount: 0,
          nextBillDate: DateFormat("dd/MM/yyyy").format(nextBillDate),
          billDay: card.billDay,
          daysToNextBill: nextBillDate
              .difference(DateTime(now.year, now.month, now.day))
              .inDays,
        );
      }).toList(),
    );

    for (CardDetails cardDetail in cardDetails) {
      await updateCardDetail(cardDetail);
    }

    return Response.success(responseBody: cardDetails);
  }

  Future<void> updateCardDetail(CardDetails cardDetail) async {
    Response txnResponse = await dbService.getTxnDetails(
      "card",
      cardDetail.cardNum,
      getPreviousDate(cardDetail.nextBillDate),
    );
    if (txnResponse.isException) return;
    cardDetail.txns = (txnResponse.responseBody as List<TblTransactions>);
    cardDetail.currentAmount = getCurrentAmount(cardDetail.txns);

    cardDetail.creditUsage = await getCreditUsage(
      cardDetail.cardNum,
      cardDetail.cardLimit,
    );
  }

  DateTime getNextBillDate(int billDay) {
    DateTime now = DateTime.now();
    DateTime current = DateTime(now.year, now.month, now.day);
    DateTime billDate = DateTime(current.year, current.month, billDay);
    if (billDate.isBefore(current)) {
      billDate = billDate.add(Duration(days: 30));
      billDate = DateTime(billDate.year, billDate.month, billDay);
    }
    return billDate;
  }

  String getPreviousDate(String date) {
    DateTime currBillDate = DateFormat("dd/MM/yyyy").parse(date);
    DateTime prevBillDate = currBillDate.subtract(Duration(days: 30));
    prevBillDate = DateTime(
      prevBillDate.year,
      prevBillDate.month,
      currBillDate.day,
    );
    return DateFormat("yyyy-MM-dd").format(prevBillDate);
  }

  double getCurrentAmount(List<TblTransactions> txns) {
    double amount = 0;
    for (TblTransactions txn in txns) {
      if (txn.isCredit == 1) {
        amount -= txn.amount;
      } else {
        amount += txn.amount;
      }
    }
    return amount;
  }

  Future<double> getCreditUsage(String cardNum, double cardLimit) async {
    Response response = await dbService.getTotalPending(cardNum);
    if (!response.isException) {
      double pending = response.responseBody as double;
      if (pending <= 0) return 0;
      double usage = (pending / cardLimit) * 100;
      return math.min(usage, 100);
    }
    return 0;
  }

  Future<bool> deleteCard(int cardId) async {
    return await dbService.deleteCard(cardId);
  }
}
