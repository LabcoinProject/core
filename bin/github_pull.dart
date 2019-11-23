import 'dart:core';

import 'package:gitcoin/gitcoin.dart';

void main() {
  Wallet wallet = Wallet.fromPem("./wallet/private_key", "./wallet/public_key.pub");
  String githubUser = "konstantinullrich";
  StorageManager storageManager = StorageManager("./storage");
  String publicKey = RsaKeyHelper.encodePublicKeyToString(wallet.publicKey);
  GithubWorker githubWorker = GithubWorker(githubUser, publicKey, storageManager, Broadcaster([]));
  githubWorker.generateRevenue();
}