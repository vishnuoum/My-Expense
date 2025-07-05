import 'package:my_expense/entity/tbl_transaction.dart';
import 'package:my_expense/services/db_service.dart';

class TransactionService {
  DBService dbService;

  TransactionService({required this.dbService});

  Future<bool> addTransaction(TblTransactions transactionDetails) async {
    return await dbService.addTransaction(transactionDetails);
  }
}
