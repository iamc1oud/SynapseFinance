import 'package:equatable/equatable.dart';

class UserMemory extends Equatable {
  final String id;
  final String key; // e.g. "preferred_account"
  final String value; // e.g. "income:salary"
  final String source; // inferred or explicit
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserMemory({
    required this.id,
    required this.key,
    required this.value,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, key, value, source, createdAt, updatedAt];
}
