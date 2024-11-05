import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/verification_center/models/bdo_family.dart';
import 'package:karanda/common/http.dart' as http;
import 'dart:developer' as developer;

class VerificationCenterNotifier with ChangeNotifier {
  List<BdoFamily> families = [];

  /*VerificationCenterNotifier(){
    getFamilies();
  }*/

  Future<void> _getFamilies() async {
    List<BdoFamily> result = [];
    final response = await http.get(Api.allFamilies);
    if (response.statusCode == 200) {
      for (Map data in jsonDecode(response.body)) {
        result.add(BdoFamily.fromData(data));
      }
      families = result;
      notifyListeners();
    }
  }

  void changeAuthState(bool authenticated) {
    if (authenticated) {
      _getFamilies();
    } else {
      families.clear();
      notifyListeners();
    }
  }

  Future<BdoFamily?> startVerify(
      String region, String code, String familyName) async {
    BdoFamily? newFamily;
    try {
      final response = await http.post(
        Api.registerFamily,
        body: jsonEncode({
          "region": region,
          "code": code,
          "familyName": familyName,
        }),
        json: true,
      );
      if (response.statusCode == 200) {
        newFamily = BdoFamily.fromData(jsonDecode(response.body));
        families.add(newFamily);
        notifyListeners();
      }
    } catch (e) {
      developer.log("Cannot connect to server");
    }
    return newFamily;
  }

  Future<BdoFamily?> verify(String region, String code) async {
    BdoFamily? newFamily;
    try {
      final response = await http.patch(
        Api.verifyFamily,
        body: jsonEncode({
          "region": region,
          "code": code,
          "familyName": "",
        }),
        json: true,
      );
      if(response.statusCode == 200){
        newFamily = BdoFamily.fromData(jsonDecode(response.body));
        int index = families.lastIndexWhere((item) => item.region == newFamily!.region && item.code == newFamily.code);
        families[index] = newFamily;
        notifyListeners();
      }
    } catch (e) {
      developer.log("Cannot connect to server");
    }
    return newFamily;
  }
}
