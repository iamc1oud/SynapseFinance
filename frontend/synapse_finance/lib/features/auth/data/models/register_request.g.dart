// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      passwordConfirm: json['password_confirm'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'password_confirm': instance.passwordConfirm,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
    };
