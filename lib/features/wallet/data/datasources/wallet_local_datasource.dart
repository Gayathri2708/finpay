import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/wallet_model.dart';

abstract class WalletLocalDataSource {
  Future<WalletModel?> getWallet();
  Future<void> cacheWallet(WalletModel wallet);
  Future<void> updateBalance(double newBalance);
  Future<void> clear();
}

class WalletLocalDataSourceImpl implements WalletLocalDataSource {
  static const _fileName = 'wallet_cache.json';

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  @override
  Future<WalletModel?> getWallet() async {
    try {
      final file = await _file;
      if (!await file.exists()) return null;
      final jsonStr = await file.readAsString();
      return WalletModel.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheWallet(WalletModel wallet) async {
    final file = await _file;
    await file.writeAsString(jsonEncode(wallet.toJson()));
  }

  @override
  Future<void> updateBalance(double newBalance) async {
    final wallet = await getWallet();
    if (wallet == null) return;
    final updated = WalletModel(
      userId: wallet.userId,
      balance: newBalance,
      currency: wallet.currency,
    );
    await cacheWallet(updated);
  }

  @override
  Future<void> clear() async {
    final file = await _file;
    if (await file.exists()) await file.delete();
  }
}
