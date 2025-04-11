import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:karanda/model/bdo_family.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/service/auth_service.dart';

class AuthController extends ChangeNotifier{
  final AuthService _authService;
  late final StreamSubscription _user;
  late final StreamSubscription _families;
  User? user;
  List<BDOFamily> families = [];

  AuthController({required AuthService authService})
      : _authService = authService{
    _user = _authService.userStream.listen(_onUserUpdate);
    _families = _authService.familiesStream.listen(_onFamiliesUpdate);
  }

  void authentication() {
    _authService.authentication();
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<void> unregister(bool? confirm) async {
    if(confirm != null && confirm){
      await _authService.unregister();
    }
  }

  void _onUserUpdate(User? value){
    user = value;
    notifyListeners();
  }

  void _onFamiliesUpdate(List<BDOFamily> value){
    families = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _user.cancel();
    _families.cancel();
    super.dispose();
  }
}
