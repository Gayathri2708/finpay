import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final bool isVerified;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.isVerified = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    phoneNumber,
    avatarUrl,
    isVerified,
    createdAt,
  ];
}
