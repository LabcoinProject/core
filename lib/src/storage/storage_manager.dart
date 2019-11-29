import 'dart:convert';
import 'dart:io';

import 'package:labcoin/labcoin.dart';

/// HowTo Read Blockchain from File
/// StorageManager storageManager = StorageManager('./storage/');
/// storageManager.BlockchainBlocks

class StorageManager {
  final String folderPath;
  Directory _pendingTransactions;
  Directory _pendingBlocks;
  Directory blockchain;
  List<File> selectedPendingTransactions = [];

  StorageManager(this.folderPath) {
    Directory directory = Directory(this.folderPath);
    if (!directory.existsSync()) directory.createSync(recursive: true);

    _pendingTransactions = Directory('${directory.path}/pendingTransactions');
    _pendingBlocks = Directory('${directory.path}/pendingBlocks');
    blockchain = Directory('${directory.path}/blockchain');

    if (!_pendingTransactions.existsSync()) _pendingTransactions.createSync();
    if (!_pendingBlocks.existsSync()) _pendingBlocks.createSync();
    if (!blockchain.existsSync()) blockchain.createSync();
  }

  /// Initialize a fresh new storage
  void init() {
    Directory directory = Directory(this.folderPath);
    directory.deleteSync(recursive: true);
    directory.createSync();

    _pendingTransactions = Directory('${directory.path}/pendingTransactions');
    _pendingBlocks = Directory('${directory.path}/pendingBlocks');
    blockchain = Directory('${directory.path}/blockchain');

    _pendingTransactions.createSync();
    _pendingBlocks.createSync();
    blockchain.createSync();
  }

  void deletePendingTransactions() {
    for (File file in selectedPendingTransactions) {
      file.delete();
    }
  }

  void deletePendingTransaction(List<Transaction> listToDelete) {
    for (Transaction trx in listToDelete) {
      String filename = '${trx.toHash()}.trx';
      File file = File('${this._pendingTransactions.path}/$filename');
      if (file.existsSync()) file.delete();
    }
  }

  TransactionList get pendingTransactions {
    TransactionList results = TransactionList();
    var files = _pendingTransactions.listSync();
    for (var file in files) {
      File ptrx = File(file.path);
      selectedPendingTransactions.add(ptrx);
      results.add(Transaction.fromMap(jsonDecode(ptrx.readAsStringSync())));
    }
    return results;
  }

  void storePendingTransaction(Transaction trx) {
    String filename = '${trx.toHash()}.trx';
    File file = File('${this._pendingTransactions.path}/$filename');
    if (!file.existsSync()) file.createSync();
    file.writeAsStringSync(jsonEncode(trx.toMap()));
  }

  void storePendingBlock(Block blc) {
    String filename = '${blc.toHash()}.blc';
    File file = File('${this._pendingBlocks.path}/$filename');
    if (!file.existsSync()) file.createSync();
    file.writeAsStringSync(jsonEncode(blc.toMap()));
  }

  List<Block> get pendingBlocks {
    List<Block> results = [];
    var files = _pendingBlocks.listSync();
    for (var file in files) {
      File pblc = File(file.path);
      results.add(Block.fromMap(jsonDecode(pblc.readAsStringSync())));
    }
    return results;
  }

  List<Block> get BlockchainBlocks {
    List<Block> results = [];
    var files = blockchain.listSync();
    files.sort((a,b) {
      String aName = a.path.split("\\").last.replaceAll(".blc", "");
      String bName = b.path.split("\\").last.replaceAll(".blc", "");
      if (int.parse(aName) > int.parse(bName))
        return 1;
      else if(int.parse(aName) < int.parse(bName))
        return -1;
      return 0;
    });
    for (var file in files) {
      File pblc = File(file.path);
      results.add(Block.fromMap(jsonDecode(pblc.readAsStringSync())));
    }
    return results;
  }

  Blockchain get storedBlockchain {
    List<Map> results = [];
    var files = blockchain.listSync();
    files.sort((a,b) {
      String aName = a.path.split("\\").last.replaceAll(".blc", "");
      String bName = b.path.split("\\").last.replaceAll(".blc", "");
      if (int.parse(aName) > int.parse(bName))
        return 1;
      else if(int.parse(aName) < int.parse(bName))
        return -1;
      return 0;
    });
    for (var file in files) {
      File pblc = File(file.path);
      results.add(jsonDecode(pblc.readAsStringSync()));
    }
    Blockchain blc = Blockchain.fromList(results);
    blc.storageManager = this;
    return blc;
  }

  void storeBlockchain(Blockchain blc_chn) {
    for (Block blc in blc_chn.chain) {
      String filename = '${blc.depth}.blc';
      File file = File('${this.blockchain.path}/$filename');
      if (!file.existsSync()) {
        file.createSync();
        file.writeAsStringSync(jsonEncode(blc.toMap()));
      }
    }
  }
}
