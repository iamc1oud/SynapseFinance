import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String? email;
  final String? firstName;
  final String? lastName;

  const User({required this.id, this.email, this.firstName, this.lastName});

  String get fullName {
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }

  @override
  List<Object?> get props => [id, email, firstName, lastName];
}
