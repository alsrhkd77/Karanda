import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'package:karanda/data_source/auth_api.dart';
import 'package:karanda/data_source/bdo_family_api.dart';
import 'package:karanda/model/bdo_family.dart';
import 'package:karanda/utils/result.dart';

import 'package:karanda/model/user.dart';
import 'package:rxdart/rxdart.dart';

class AuthRepository {
  late final AuthApi _authApi;
  late final BDOFamilyApi _familyApi;
  final String _accessTokenKey = "karanda-token";
  final String _refreshTokenKey = "refresh-token";
  final _user = BehaviorSubject<User?>()..sink.add(null);

  Stream<User?> get userStream => _user.stream;

  bool get authenticated => _user.value != null;

  AuthRepository({required AuthApi authApi, required BDOFamilyApi familyApi})
      : _authApi = authApi,
        _familyApi = familyApi;

  Future<bool> login() async {
    const storage = FlutterSecureStorage();
    if (await storage.containsKey(key: _accessTokenKey)) {
      final result = await _authApi.authorization();
      switch (result) {
        case Ok<User>():
          _user.sink.add(result.value);
          return true;
        case Error<User>():
          _user.sink.add(null);
          await clearToken();
          return false;
      }
    }
    return false;
  }

  Future<void> logout() async {
    _user.sink.add(null);
    await clearToken();
  }

  void authentication({
    required Future<void> Function(String, String) onSuccess,
    required Future<void> Function() onFailed,
  }) {
    if (kIsWeb) {
      _authApi.authenticationWeb();
    } else {
      _authApi.listenRedirect(
        onSuccess: onSuccess,
        onFailed: onFailed,
      );
      _authApi.authenticationWindows();
    }
  }

  Future<bool> unregister() async {
    return await _authApi.unregister();
  }

  Future<void> saveToken({
    required String accessToken,
    required String refreshToken,
  }) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: _accessTokenKey, value: accessToken);
    await storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clearToken() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: _accessTokenKey);
    await storage.delete(key: _refreshTokenKey);
  }
}
