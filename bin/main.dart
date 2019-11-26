import 'dart:io';
import 'dart:isolate';

import 'package:labcoin/labcoin.dart';

Wallet wallet = Wallet.fromPem('./wallet/private_key', './wallet/public_key.pub');
StorageManager storageManager = StorageManager('./storage/');
String githubUser = 'konstantinullrich';
int webPort = 3000;
Broadcaster broadcaster = Broadcaster([]);

void runBlockchainValidator(dynamic d) {
  Blockchain blockchain = Blockchain(wallet, storageManager, broadcaster: broadcaster);
  if (storageManager.BlockchainBlocks.length >= 1) {
    print('loading existing Blockchain');
    blockchain = storageManager.storedBlockchain;
    blockchain.creatorWallet = wallet;
    blockchain.broadcaster = broadcaster;
  }
  while(true) {
    if (storageManager.pendingTransactions.length > 2) {
      print('Start mining a Block');
      final stopwatch = Stopwatch()..start();
      blockchain.createBlock();
      print('The mining Process was completed in ${stopwatch.elapsed}');
    } else {
      sleep(Duration(seconds: 10));
    }
  }
}

void runWebServer(dynamic d) {
  RestHandler restHandler = RestHandler(storageManager, webPort);
  restHandler.run();
}

void main() {
  ReceivePort receivePort= ReceivePort();
  Future<Isolate> blockchainValidator = Isolate.spawn(runBlockchainValidator, receivePort.sendPort);
  Future<Isolate> webServer = Isolate.spawn(runWebServer, receivePort.sendPort);
}