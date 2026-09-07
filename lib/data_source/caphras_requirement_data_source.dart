import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:karanda/model/caphras_requirement.dart';

class CaphrasRequirementDataSource {
  static const String _assetPath = "assets/data/caphras_requirements.json";

  Future<List<CaphrasRequirementGroup>> load() async {
    final data = await rootBundle.loadString(_assetPath);
    final Map json = jsonDecode(data);
    final groups = json["groups"];
    if (groups is! List) {
      return const [];
    }
    return groups
        .map((group) => CaphrasRequirementGroup.fromJson(group))
        .toList();
  }
}
