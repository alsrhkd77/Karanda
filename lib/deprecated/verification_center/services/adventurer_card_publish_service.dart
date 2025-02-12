import 'dart:async';
import 'dart:convert';

import 'package:karanda/common/api.dart';
import 'package:karanda/common/enums/adventurer_card_background.dart';
import 'package:karanda/common/rest_client.dart';
import 'package:karanda/deprecated/verification_center/models/adventurer_card.dart';
import 'package:karanda/deprecated/verification_center/models/bdo_family.dart';
import 'package:karanda/deprecated/verification_center/models/simplified_adventurer_card.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:developer' as developer;

class AdventurerCardPublishService {
  final _adventurerCard = BehaviorSubject<AdventurerCard>();
  late final BdoFamily _family;

  Stream<AdventurerCard> get cardData => _adventurerCard.stream;

  AdventurerCardPublishService({required BdoFamily family}) {
    _family = family;
    _adventurerCard.sink.add(AdventurerCard.preview(family));
  }

  Future<void> setBackground(AdventurerCardBackground selected) async {
    final data = _adventurerCard.value;
    data.background = selected;
    _adventurerCard.sink.add(data);
  }

  void setFamilyNameOption(bool? value) {
    if (value != null) {
      final data = _adventurerCard.value;
      data.familyName = value ? _family.familyName : "";
      _adventurerCard.sink.add(data);
    }
  }

  void setKeywords(String? value) {
    final data = _adventurerCard.value;
    value = value ?? "";
    data.keywords = value.replaceAll(' ', '');
    _adventurerCard.sink.add(data);
  }

  Future<SimplifiedAdventurerCard?> publish() async {
    try {
      final response = await RestClient.post(
        Api.publishAdventurerCard,
        body: jsonEncode({
          "code":_family.code,
          "region":_family.region,
          "background":_adventurerCard.value.background.name,
          "keywords":_adventurerCard.value.keywords,
          "showFamilyName":_adventurerCard.value.familyName.isNotEmpty,
        }),
        json: true,
        retry: true,
      );
      if(response.statusCode == 200){
        return SimplifiedAdventurerCard.fromJson(jsonDecode(response.body));
      } else {
        developer.log(response.toString());
      }
    } catch (e) {
      developer.log(e.toString());
    }
    return null;
  }

  void dispose() {
    _adventurerCard.close();
  }
}
