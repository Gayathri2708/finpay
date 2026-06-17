import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.fromUserId,
    required super.toUserId,
    required super.amount,
    required super.type,
    required super.status,
    required super.description,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      fromUserId: json['from_user_id'] as String,
      toUserId: json['to_user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.byName(json['type'] as String),
      status: TransactionStatus.values.byName(json['status'] as String),
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'amount': amount,
      'type': type.name,
      'status': status.name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      fromUserId: entity.fromUserId,
      toUserId: entity.toUserId,
      amount: entity.amount,
      type: entity.type,
      status: entity.status,
      description: entity.description,
      createdAt: entity.createdAt,
    );
  }
}
