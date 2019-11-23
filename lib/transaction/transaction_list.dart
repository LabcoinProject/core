import 'package:gitcoin/transaction/transaction.dart';

class TransactionList {
  List<Transaction> _trx = [];

  void add(Transaction trx) {
    this._trx.add(trx);
  }
  
  bool get isValid {
    for (Transaction trx in this._trx) {
      if (!trx.isValid) return false;
    }
    return true;
  }
  
  List<Map> toList() {
    List<Map> result = [];
    for (Transaction trx in this._trx) {
      result.add(trx.toMap());
    }
    return result;
  }
  
  String toString() {
    String result = "";
    for (Transaction trx in this._trx) {
      result += trx.toString();
    }
    return result;
  }
}