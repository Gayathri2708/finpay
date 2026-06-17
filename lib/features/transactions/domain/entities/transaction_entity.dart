import 'package:equatable/equatable.dart';

enum TransactionType { credit, debit }

enum TransactionStatus { pending, completed, failed }

class TransactionEntity extends Equatable {
  final String id;
  final String fromUserId;
  final String toUserId;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final String description;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.type,
    required this.status,
    required this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    fromUserId,
    toUserId,
    amount,
    type,
    status,
    description,
    createdAt,
  ];
}
