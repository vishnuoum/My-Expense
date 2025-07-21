import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:my_expense/entity/tbl_card.dart';
import 'package:my_expense/entity/tbl_template.dart';
import 'package:my_expense/entity/tbl_transaction.dart';
import 'package:my_expense/models/response.dart';
import 'package:my_expense/models/transaction_listing_details.dart';
import 'package:sqflite/sqflite.dart';

class DBService {
  late Database database;

  Future<bool> initDB() async {
    try {
      var databasesPath = await getDatabasesPath();
      String path = "$databasesPath/transactions.db";

      // await deleteDatabase(path);
      database = await openDatabase(
        // inMemoryDatabasePath,
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          log("Creating transactions table");
          await db.execute(
            """CREATE TABLE IF NOT EXISTS transactions (id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL,uniqueId TEXT,txnType TEXT, isCredit BOOLEAN, date Date,merchant TEXT,category TEXT);""",
          );

          log("Creating cards table");
          await db.execute(
            """CREATE TABLE IF NOT EXISTS cards (id INTEGER PRIMARY KEY AUTOINCREMENT,cardNo TEXT UNIQUE,
            cardName TEXT,cardLimit REAL,billDay INTEGER);""",
          );

          log("Creating sms template table");
          await db.execute(
            """CREATE TABLE IF NOT EXISTS templates (id INTEGER PRIMARY KEY AUTOINCREMENT, patternName TEXT, pattern TEXT, amountGroup INTEGER, 
            uniqueIdGroup INTEGER, merchantGroup INTEGER, dateGroup INTEGER, isCredit BOOLEAN, txnType TEXT, dateFormat TEXT)""",
          );
        },
        onOpen: (Database db) async {
          // When opening the db, create the table
          log("Creating transactions table");
          await db.execute(
            """CREATE TABLE IF NOT EXISTS transactions (id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL,uniqueId TEXT,txnType TEXT, isCredit BOOLEAN, date Date,merchant TEXT,category TEXT);""",
          );

          log("Creating cards table");
          await db.execute(
            """CREATE TABLE IF NOT EXISTS cards (id INTEGER PRIMARY KEY AUTOINCREMENT,cardNo TEXT UNIQUE,
            cardName TEXT,cardLimit REAL,billDay INTEGER);""",
          );

          log("Creating sms template table");
          await db.execute(
            """CREATE TABLE IF NOT EXISTS templates (id INTEGER PRIMARY KEY AUTOINCREMENT, patternName TEXT, pattern TEXT, amountGroup INTEGER, 
            uniqueIdGroup INTEGER, merchantGroup INTEGER, dateGroup INTEGER, isCredit BOOLEAN, txnType TEXT, dateFormat TEXT)""",
          );
        },
      );
      log('initDB() success');
      return true;
    } catch (error) {
      log('initDB() error: $error');
      return false;
    }
  }

  Future<Response> addCard(TblCards card) async {
    try {
      final existing = await database.query(
        "cards",
        where: "cardNo = ?",
        whereArgs: [card.cardNo],
      );
      if (existing.isNotEmpty) {
        if (card.id != existing.first["id"]) {
          log("duplicate card No.");
          return Response.error();
        }
      }
      int id = await database.insert(
        "cards",
        card.getMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Response.success(responseBody: id);
    } catch (error) {
      log("addCard() failed: $error");
      return Response.error();
    }
  }

  Future<Response> addTransaction(TblTransactions transaction) async {
    try {
      return Response.success(
        responseBody: await database.insert(
          "transactions",
          transaction.getMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        ),
      );
    } catch (error) {
      log("addTransaction() failed: $error");
      return Response.error();
    }
  }

  Future<Response> getAllCards() async {
    try {
      List<Map<String, dynamic>> maps = await database.query("cards");
      log("getAllCards: $maps");
      List<TblCards> cards = maps.map((map) => TblCards.fromMap(map)).toList();
      return Response.success(responseBody: cards);
    } catch (error) {
      log("Error while fetching cards $error");
      return Response.error();
    }
  }

  Future<Response> getTxnDetails(
    String txnType,
    String uniqueId,
    String date,
  ) async {
    try {
      List<Map<String, dynamic>> maps = await database.query(
        "transactions",
        where: "txnType = ? and uniqueId = ? and date > ?",
        whereArgs: [txnType, uniqueId, date],
        orderBy: "id desc",
      );
      log("getTxnDetails: $maps");
      List<TblTransactions> txns = maps
          .map((map) => TblTransactions.fromMap(map))
          .toList();
      return Response.success(responseBody: txns);
    } catch (error) {
      log("Error while fetching cards $error");
      return Response.error();
    }
  }

  Future<Response> getAllTransactionsWithinRange(
    TransactionListingDetails transactionDetails,
  ) async {
    try {
      List<Map<String, dynamic>> result = await database.query(
        "transactions",
        where: "uniqueId like ? and txnType = ? and date BETWEEN ? and ? ",
        whereArgs: [
          transactionDetails.uniqueId,
          transactionDetails.txnType,
          transactionDetails.from,
          transactionDetails.to,
        ],
      );
      log(
        "Transaction within range ${transactionDetails.from} - ${transactionDetails.to} $result",
      );
      return Response.success(
        responseBody: result
            .map((item) => TblTransactions.fromMap(item))
            .toList(),
      );
    } catch (error) {
      log(
        "Error while fethcing all transactions within range ${transactionDetails.from} - ${transactionDetails.to} $error",
      );
      return Response.error();
    }
  }

  Future<Response> getTotalPending(String cardNum) async {
    try {
      List<Map<String, dynamic>> result = await database.rawQuery(
        """Select (Coalesce((Select sum(amount) from transactions where uniqueId = ? and txnType = 'card'  and isCredit = 0), 0.0) - 
        Coalesce((Select sum(amount) from transactions where uniqueId = ? and txnType = 'card' and isCredit = 1), 0.0)) as totalPendingCreditAmount""",
        [cardNum, cardNum],
      );
      return Response.success(
        responseBody: result[0]["totalPendingCreditAmount"],
      );
    } catch (error) {
      log("Error while fetching usage: $error");
      return Response.error();
    }
  }

  Future<bool> deleteCard(int cardId) async {
    try {
      await database.delete("cards", where: "id = ?", whereArgs: [cardId]);
      return true;
    } catch (error) {
      log("Error while deleting card");
      return false;
    }
  }

  Future<Response> getCurrentCashBalance() async {
    try {
      List<Map<String, dynamic>> result = await database.rawQuery(
        """Select Coalesce((Select sum(amount) from transactions where txnType = 'cash' and isCredit = 1),0.0) - 
        Coalesce((Select sum(amount) from transactions where txnType = 'cash' and isCredit = 0), 0.0) as currentBalance;""",
      );
      return Response.success(
        responseBody: result[0]["currentBalance"] as double,
      );
    } catch (error) {
      log("Error while fetching cash balance $error");
      return Response.error();
    }
  }

  Future<Response> getRecentCashTxns() async {
    try {
      DateTime currentDate = DateTime.now();
      DateTime startOfMonth = DateTime(currentDate.year, currentDate.month, 1);
      List<Map<String, dynamic>> maps = await database.query(
        "transactions",
        where: "txnType = ? and date >= ?",
        whereArgs: ["cash", DateFormat("yyyy-MM-dd").format(startOfMonth)],
        orderBy: "id desc",
      );
      return Response.success(
        responseBody: maps.map((map) => TblTransactions.fromMap(map)).toList(),
      );
    } catch (error) {
      log("Error while fetching cash transactions ${error}");
      return Response.error();
    }
  }

  Future<bool> deleteTxn(int id) async {
    try {
      await database.delete("transactions", where: "id = ?", whereArgs: [id]);
      return true;
    } catch (error) {
      log("Error while deleting transactions $error");
      return false;
    }
  }

  Future<Response> getAllTemplates() async {
    try {
      List<Map<String, dynamic>> result = await database.query("templates");
      log("Template $result");
      return Response.success(
        responseBody: result.map((map) => TblTemplate.fromMap(map)).toList(),
      );
    } catch (error) {
      log("Error while fethcing templates $error");
      return Response.error();
    }
  }

  Future<Response> addTemplate(TblTemplate template) async {
    try {
      return Response.success(
        responseBody: await database.insert(
          "templates",
          template.getMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        ),
      );
    } catch (error) {
      log("Error while adding the template $error");
      return Response.error();
    }
  }

  Future<bool> deleteTemplate(int id) async {
    try {
      await database.delete("templates", where: "id = ?", whereArgs: [id]);
      return true;
    } catch (error) {
      log("Error while deleting template $error");
      return false;
    }
  }
}
