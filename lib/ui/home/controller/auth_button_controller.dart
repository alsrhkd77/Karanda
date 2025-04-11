import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/service/auth_service.dart';

class AuthButtonController extends ChangeNotifier {
  final AuthService _authService;
  final GoRouter _router;
  late final StreamSubscription _user;

  bool get waitResponse => _authService.waitResponse;

  User? user;

  AuthButtonController(
      {required AuthService authService, required GoRouter router})
      : _authService = authService,
        _router = router {
    _user = _authService.userStream.listen(_onUpdateUser);
  }

  void onClick() {
    if (_authService.authenticated) {
      _router.go("/auth");
    } else {
      _authService.authentication();
    }
  }

  void update() => notifyListeners();

  void _onUpdateUser(User? value) {
    user = value;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _user.cancel();
    super.dispose();
  }
}
