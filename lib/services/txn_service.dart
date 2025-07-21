import 'package:my_expense/entity/tbl_transaction.dart';
import 'package:my_expense/models/response.dart';
import 'package:my_expense/services/db_service.dart';

class TransactionService {
  DBService dbService;

  TransactionService({required this.dbService});

  Future<Response> addTransaction(TblTransactions transactionDetails) async {
    return await dbService.addTransaction(transactionDetails);
  }

  Future<bool> deleteTxn(int id) async {
    return await dbService.deleteTxn(id);
  }
}
