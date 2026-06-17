import '../../domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.userId,
    required super.balance,
    super.currency,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      userId: json['user_id'] as String,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'balance': balance,
      'currency': currency,
    };
  }

  factory WalletModel.fromEntity(WalletEntity entity) {
    return WalletModel(
      userId: entity.userId,
      balance: entity.balance,
      currency: entity.currency,
    );
  }
}
