import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:karanda/horse_status/models/horse_equipment_model.dart';
import 'package:karanda/horse_status/models/horse_model.dart';

class HorseStatusDataController {
  final _horseController = StreamController();
  final _horseEquipmentController = StreamController();
  List<HorseModel> _breeds = [];
  List<HorseEquipmentModel> _equipments = [];

  HorseStatusDataController(){
    getBaseData();
  }

  Future<void> getBaseData() async {
    try {
      Map data = jsonDecode(
          await rootBundle.loadString('assets/data/horse_status.json'));
      for(String key in data['breed'].keys()){
        _breeds.add(HorseModel.fromData(data['breed'][key]));
      }
      for(String key in data['equipment'].keys()){
        _equipments.add(HorseEquipmentModel.fromData(data['equipment'][key]));
      }
    } catch (e) {
      print(e);
    }
  }
}