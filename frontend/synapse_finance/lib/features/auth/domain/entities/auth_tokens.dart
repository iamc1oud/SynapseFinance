import 'package:equatable/equatable.dart';

class AuthTokens extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, tokenType];
}
