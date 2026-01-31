import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/auth_tokens.dart';

part 'auth_tokens_model.g.dart';

@JsonSerializable()
class AuthTokensModel extends AuthTokens {
  const AuthTokensModel({
    @JsonKey(name: 'access_token') required super.accessToken,
    @JsonKey(name: 'refresh_token') required super.refreshToken,
    @JsonKey(name: 'token_type') required super.tokenType,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokensModelToJson(this);
}
