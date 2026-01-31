import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/storage_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/token_storage.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
  Future<bool> isLoggedIn();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _sharedPreferences;
  final TokenStorage _tokenStorage;

  static const String _cachedUserKey = 'cached_user';

  AuthLocalDataSourceImpl(this._sharedPreferences, this._tokenStorage);

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _sharedPreferences.setString(_cachedUserKey, userJson);
    } catch (e) {
      throw CacheException('Failed to cache user: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = _sharedPreferences.getString(_cachedUserKey);
      if (userJson == null) return null;
      return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (e) {
      throw CacheException('Failed to get cached user: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    await Future.wait([
      _sharedPreferences.remove(_cachedUserKey),
      _sharedPreferences.remove(StorageConstants.userId),
      _sharedPreferences.remove(StorageConstants.userEmail),
      _tokenStorage.clearTokens(),
    ]);
  }

  @override
  Future<bool> isLoggedIn() async {
    return _tokenStorage.hasValidToken();
  }
}

@module
abstract class SharedPreferencesModule {
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();
}
