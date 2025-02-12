import 'dart:async';
import 'dart:convert';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/http.dart' as http;
import 'package:karanda/common/rest_client.dart';
import 'package:karanda/deprecated/verification_center/models/bdo_family.dart';
import 'package:karanda/deprecated/verification_center/models/simplified_adventurer_card.dart';
import 'dart:developer' as developer;

import 'package:rxdart/rxdart.dart';

class VerificationCenterDataController {
  final _families = BehaviorSubject<List<BdoFamily>>();

  Stream<List<BdoFamily>> get families => _families.stream;

  Stream<List<SimplifiedAdventurerCard>> get adventurerCards =>
      families.map(_toAdventurerCards);

  //List<BdoFamily> get families => _family;

  VerificationCenterDataController() {
    getFamilies();
  }

  List<SimplifiedAdventurerCard> _toAdventurerCards(List<BdoFamily> data) {
    return data.expand((item) => item.adventurerCards).toList();
  }

  Future<void> getFamilies() async {
    List<BdoFamily> result = [];
    final response = await http.get(Api.allFamilies);
    if (response.statusCode == 200) {
      for (Map data in jsonDecode(response.body)) {
        result.add(BdoFamily.fromData(data));
      }
      _families.sink.add(result);
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
        final snapshot = _families.value;
        snapshot.add(newFamily);
        _families.sink.add(snapshot);
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
        final snapshot = _families.value;
        int index = snapshot.lastIndexWhere((item) =>
            item.region == newFamily!.region && item.code == newFamily.code);
        snapshot[index] = newFamily;
        _families.sink.add(snapshot);
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
        final snapshot = _families.value;
        snapshot
            .removeWhere((item) => item.region == region && item.code == code);
        _families.sink.add(snapshot);
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
        final snapshot = _families.value;
        int index = snapshot.lastIndexWhere((item) =>
            item.region == family!.region && item.code == family.code);
        snapshot[index] = family;
        _families.sink.add(snapshot);
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

  void addAdventurerCard(SimplifiedAdventurerCard card, BdoFamily family){
    final snapshot = _families.value;
    int index = snapshot.indexWhere((item) => item.isSame(family));
    snapshot[index].adventurerCards.add(card);
    _families.sink.add(snapshot);
  }

  Future<bool> deleteAdventurerCard(String code) async {
    bool result = false;
    try {
      final response = await RestClient.delete(
        Api.deleteAdventurerCard,
        body: {"code": code},
      );
      if(response.statusCode == 204 || response.statusCode == 200){
        result = true;
        final snapshot = _families.value;
        for (BdoFamily item in snapshot) {
          item.removeAdventurerCard(code);
        }
        _families.sink.add(snapshot);
      }
    } catch (e) {
      developer.log("Cannot connect to server\n$e");
    }
    return result;
  }

  void dispose(){
    _families.close();
  }
}
