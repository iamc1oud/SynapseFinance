import 'package:json_annotation/json_annotation.dart';

import 'auth_tokens_model.dart';
import 'user_model.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  final UserModel user;
  final AuthTokensModel tokens;

  const LoginResponse({required this.user, required this.tokens});

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
