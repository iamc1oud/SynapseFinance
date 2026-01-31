import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    @JsonKey(name: 'first_name') super.firstName,
    @JsonKey(name: 'last_name') super.lastName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(User user) => UserModel(
    id: user.id,
    email: user.email,
    firstName: user.firstName,
    lastName: user.lastName,
  );
}
