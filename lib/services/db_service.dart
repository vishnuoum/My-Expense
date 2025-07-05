import 'dart:developer';

import 'package:my_expense/entity/tbl_card.dart';
import 'package:my_expense/entity/tbl_transaction.dart';
import 'package:my_expense/models/response.dart';
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
        },
      );
      log('initDB() success');
      return true;
    } catch (error) {
      log('initDB() error: $error');
      return false;
    }
  }

  Future<bool> addCard(TblCards card) async {
    try {
      await database.insert(
        "cards",
        card.getMap(),
        conflictAlgorithm: ConflictAlgorithm.rollback,
      );
      return true;
    } catch (error) {
      log("addCard() failed: $error");
      return false;
    }
  }

  Future<bool> addTransaction(TblTransactions transaction) async {
    try {
      await database.insert(
        "transactions",
        transaction.getMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (error) {
      log("addTransaction() failed: $error");
      return false;
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
      log("${await database.query("transactions")}");
      List<Map<String, dynamic>> maps = await database.query(
        "transactions",
        where: "txnType = ? and uniqueId = ? and date > ?",
        whereArgs: [txnType, uniqueId, date],
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
}
