import 'dart:developer';

import 'package:my_expense/entity/tbl_card.dart';
import 'package:my_expense/entity/tbl_transaction.dart';
import 'package:my_expense/models/response.dart';
import 'package:sqflite/sqflite.dart';

class DBService {
  late Database database;

  Future<bool> initDB() async {
    try {
      // var databasesPath = await getDatabasesPath();
      // String path = "$databasesPath/transactions.db";

      // await deleteDatabase(path);
      database = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
            """CREATE TABLE IF NOT EXISTS transactions (id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL,uniqueId TEXT,txnType TEXT, isDebit BOOLEAN, date TEXT,merchant TEXT,category TEXT);""",
          );

          await db.execute(
            """CREATE TABLE IF NOT EXISTS cards (id INTEGER PRIMARY KEY AUTOINCREMENT,cardNo TEXT UNIQUE,
            cardName TEXT,cardLimit TEXT,billDay INTEGER);""",
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

  Future<Response> getTxnDetails(String txnType, String date) async {
    try {
      List<Map<String, dynamic>> maps = await database.query(
        "transactions",
        where: "txnType = ? and date > ?",
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
