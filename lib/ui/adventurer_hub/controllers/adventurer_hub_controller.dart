import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/service/adventurer_hub_service.dart';

class AdventurerHubController extends ChangeNotifier {
  final AdventurerHubService _adventurerHubService;
  late final StreamSubscription _user;

  User? user;

  AdventurerHubController({
    required AdventurerHubService adventurerHubService,
  }) : _adventurerHubService = adventurerHubService {
    _user = _adventurerHubService.userStream.listen(_onUserUpdate);
  }

  bool get authenticated => user != null;

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
