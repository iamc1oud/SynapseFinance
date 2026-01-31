import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../constants/storage_constants.dart';

@lazySingleton
class TokenStorage {
  final FlutterSecureStorage _secureStorage;

  TokenStorage(this._secureStorage);

  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: StorageConstants.accessToken);
  }

  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: StorageConstants.accessToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: StorageConstants.refreshToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(
      key: StorageConstants.refreshToken,
      value: token,
    );
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: StorageConstants.accessToken),
      _secureStorage.delete(key: StorageConstants.refreshToken),
    ]);
  }

  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

@module
abstract class SecureStorageModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
}
