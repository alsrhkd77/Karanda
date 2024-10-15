import 'dart:async';
import 'dart:convert';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/http.dart' as http;

class VerificationCenterDataController {
  Future<void> startVerification(
      String region, String code, String familyName) async {
    await http.post(
      Api.startFamilyVerification,
      body: jsonEncode({
        "region": region,
        "code": code,
        "familyName": familyName,
      }),
      json: true,
    );
  }
}
