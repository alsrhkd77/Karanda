import 'dart:async';
import 'dart:convert';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/http.dart' as http;
import 'package:karanda/verification_center/models/bdo_family.dart';
import 'dart:developer' as developer;

class VerificationCenterDataController {
  List<BdoFamily> _family = [];
  final StreamController<List<BdoFamily>> _familyListDataController =
      StreamController<List<BdoFamily>>();

  Stream<List<BdoFamily>> get familyListStream =>
      _familyListDataController.stream;

  List<BdoFamily> get families => _family;

  VerificationCenterDataController() {
    getFamilies();
  }

  Future<void> getFamilies() async {
    List<BdoFamily> result = [];
    final response = await http.get(Api.allFamilies);
    if (response.statusCode == 200) {
      for (Map data in jsonDecode(response.body)) {
        result.add(BdoFamily.fromData(data));
      }
      _family = result;
      _familyListDataController.sink.add(_family);
    }
  }

  Future<BdoFamily?> register(
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
        _family.add(newFamily);
        _familyListDataController.sink.add(_family);
      }
    } catch (e) {
      developer.log("Cannot connect to server\n$e");
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
      if (response.statusCode == 200) {
        newFamily = BdoFamily.fromData(jsonDecode(response.body));
        int index = _family.lastIndexWhere((item) =>
            item.region == newFamily!.region && item.code == newFamily.code);
        _family[index] = newFamily;
        _familyListDataController.sink.add(_family);
      }
    } catch (e) {
      developer.log("Cannot connect to server\n$e");
    }
    return newFamily;
  }

  Future<bool> unregister(String region, String code) async {
    bool result = false;
    try {
      final response = await http.delete(
        Api.unregisterFamily,
        body: jsonEncode({
          "region": region,
          "code": code,
          "familyName": "",
        }),
        json: true,
      );
      if (response.statusCode == 204 || response.statusCode == 200) {
        _family
            .removeWhere((item) => item.region == region && item.code == code);
        _familyListDataController.sink.add(_family);
        result = true;
      }
    } catch (e) {
      developer.log("Cannot connect to server\n$e");
    }
    return result;
  }

  Future<BdoFamily?> refresh(String region, String code) async {
    BdoFamily? family;
    try {
      final response = await http.patch(
        Api.refreshFamilyData,
        body: jsonEncode({
          "region": region,
          "code": code,
          "familyName": "",
        }),
        json: true,
      );
      if (response.statusCode == 200) {
        family = BdoFamily.fromData(jsonDecode(response.body));
        int index = _family.lastIndexWhere((item) =>
            item.region == family!.region && item.code == family.code);
        _family[index] = family;
        _familyListDataController.sink.add(_family);
      }
    } catch (e) {
      developer.log("Cannot connect to server\n$e");
    }
    return family;
  }

  Future<bool> setMain(String region, String code) async {
    bool result = false;
    try {
      final response = await http.patch(
        Api.setMainFamily,
        body: jsonEncode({
          "region": region,
          "code": code,
          "familyName": "",
        }),
        json: true,
      );
      if (response.statusCode == 204 || response.statusCode == 200) {
        result = true;
      }
    } catch (e) {
      developer.log("Cannot connect to server\n$e");
    }
    return result;
  }
}
