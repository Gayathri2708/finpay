import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getTransactions({
    required int page,
    required int limit,
  });
  Future<void> cacheTransactions(List<TransactionModel> transactions);
  Future<void> addTransaction(TransactionModel transaction);
  Future<List<TransactionModel>> getPendingTransactions();
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> clear();
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  static const _fileName = 'transactions_cache.json';

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<TransactionModel>> _readAll() async {
    try {
      final file = await _file;
      if (!await file.exists()) return [];
      final jsonStr = await file.readAsString();
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => TransactionModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeAll(List<TransactionModel> transactions) async {
    final file = await _file;
    final jsonList = transactions.map((t) => t.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  @override
  Future<List<TransactionModel>> getTransactions({
    required int page,
    required int limit,
  }) async {
    final all = await _readAll();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final start = (page - 1) * limit;
    if (start >= all.length) return [];
    final end = (start + limit).clamp(0, all.length);
    return all.sublist(start, end);
  }

  @override
  Future<void> cacheTransactions(List<TransactionModel> transactions) async {
    final existing = await _readAll();
    final map = {for (final t in existing) t.id: t};
    for (final t in transactions) {
      map[t.id] = t;
    }
    await _writeAll(map.values.toList());
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    final all = await _readAll();
    all.insert(0, transaction);
    await _writeAll(all);
  }

  @override
  Future<List<TransactionModel>> getPendingTransactions() async {
    final all = await _readAll();
    return all.where((t) => t.status.name == 'pending').toList();
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    final all = await _readAll();
    final index = all.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      all[index] = transaction;
      await _writeAll(all);
    }
  }

  @override
  Future<void> clear() async {
    final file = await _file;
    if (await file.exists()) await file.delete();
  }
}
