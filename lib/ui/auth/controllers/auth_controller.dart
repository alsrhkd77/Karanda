import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/service/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService;
  late final StreamSubscription _user;
  User? user;

  AuthController({required AuthService authService})
      : _authService = authService {
    _user = _authService.userStream.listen(_onUserUpdate);
  }

  Future<bool> registerFamily({
    required BDORegion region,
    required String code,
    required String familyName,
  }) async {
    return await _authService.registerFamily(
      region: region,
      code: code,
      familyName: familyName,
    );
  }

  Future<bool> unregisterFamily() async {
    return await _authService.unregisterFamily();
  }

  Future<bool> updateFamilyData() async {
    return await _authService.updateFamilyData();
  }

  void authentication() {
    _authService.authentication();
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<void> unregister(bool? confirm) async {
    if (confirm != null && confirm) {
      await _authService.unregister();
    }
  }

  void _onUserUpdate(User? value) {
    user = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _user.cancel();
    super.dispose();
  }
}
