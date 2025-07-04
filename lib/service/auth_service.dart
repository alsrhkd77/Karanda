import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/repository/auth_repository.dart';

import 'package:karanda/model/user.dart';

import '../enums/bdo_region.dart';

class AuthService extends ChangeNotifier {
  final AuthRepository _authRepository;
  final GoRouter _router;
  late final StreamSubscription _user;

  bool waitResponse = false;

  bool get authenticated => _authRepository.authenticated;

  Stream<User?> get userStream => _authRepository.userStream;

  AuthService({
    required AuthRepository authRepository,
    required GoRouter router,
  })  : _authRepository = authRepository,
        _router = router {
    _user = _authRepository.userStream.listen((value) => notifyListeners());
    if (kIsWeb) {
      login();
    }
  }

  Future<bool> login() async {
    waitResponse = true;
    notifyListeners();
    final result = await _authRepository.login();
    waitResponse = false;
    notifyListeners();
    return result;
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _router.go("/");
  }

  Future<void> unregister() async {
    final result = await _authRepository.unregister();
    if (result) {
      await _authRepository.logout();
      _router.go("/");
    } else {
      //TODO: 탈퇴 실패 스낵바 필요
    }
  }

  Future<void> processingTokens(String token, String refreshToken) async {
    await _authRepository.saveToken(
      accessToken: token,
      refreshToken: refreshToken,
    );
    if (await login()) {
      _router.go("/");
    } else {
      _router.go("auth/error");
    }
  }

  void authentication() {
    _authRepository.authentication(
      onSuccess: (accessToken, refreshToken) async {
        await _authRepository.saveToken(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        _router.go(Uri(path: "/auth/authenticate", queryParameters: {
          'token': accessToken,
          'refresh-token': refreshToken
        }).toString());
      },
      onFailed: () async {
        await _authRepository.clearToken();
        //TODO: 로그인 실패 스낵바 필요
      },
    );
  }

  Future<bool> registerFamily({
    required BDORegion region,
    required String code,
    required String familyName,
  }) async {
    return await _authRepository.registerFamily(
      region: region,
      code: code,
      familyName: familyName,
    );
  }

  Future<bool> unregisterFamily() async {
    return await _authRepository.unregisterFamily();
  }

  Future<bool> updateFamilyData() async {
    return await _authRepository.updateFamilyData();
  }

  @override
  void dispose() {
    _user.cancel();
    super.dispose();
  }
}
