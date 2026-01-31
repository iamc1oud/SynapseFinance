import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';

part 'auth_api_client.g.dart';

@lazySingleton
@RestApi()
abstract class AuthApiClient {
  @factoryMethod
  factory AuthApiClient(Dio dio) = _AuthApiClient;

  @POST(ApiConstants.login)
  Future<LoginResponse> login(@Body() LoginRequest request);

  @POST(ApiConstants.register)
  Future<LoginResponse> register(@Body() RegisterRequest request);

  @POST(ApiConstants.logout)
  Future<void> logout(@Body() Map<String, String> refreshToken);

  @GET(ApiConstants.user)
  Future<UserModel> getCurrentUser();
}
