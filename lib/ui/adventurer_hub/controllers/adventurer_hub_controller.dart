import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/service/adventurer_hub_service.dart';

import '../../../model/recruitment.dart';

class AdventurerHubController extends ChangeNotifier {
  final AdventurerHubService _adventurerHubService;
  late final StreamSubscription _user;
  late final StreamSubscription _recruitments;

  User? user;
  List<Recruitment>? recruitments;

  AdventurerHubController({
    required AdventurerHubService adventurerHubService,
  }) : _adventurerHubService = adventurerHubService {
    _user = _adventurerHubService.userStream.listen(_onUserUpdate);
    _recruitments =
        adventurerHubService.recruitmentsStream.listen(_onRecruitmentsUpdate);
  }

  bool get authenticated => user != null;

  void _onUserUpdate(User? value) {
    user = value;
    notifyListeners();
  }

  void _onRecruitmentsUpdate(List<Recruitment> value) {
    recruitments = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _user.cancel();
    _recruitments.cancel();
    super.dispose();
  }
}
