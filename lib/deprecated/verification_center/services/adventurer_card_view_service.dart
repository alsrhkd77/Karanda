import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/file_saver/file_saver.dart';
import 'package:karanda/common/http_response_extension.dart';
import 'package:karanda/common/rest_client.dart';
import 'dart:developer' as developer;

import 'package:karanda/deprecated/verification_center/models/adventurer_card.dart';

class AdventurerCardViewService extends ChangeNotifier {
  final imageKey = GlobalKey();
  AdventurerCard? adventurerCardData;
  String? errorMsg;

  AdventurerCardViewService({required String code}){
    getData(code);
  }

  Future<void> getData(String code) async {
    try {
      final response = await RestClient.get(
        Api.adventurerCardDetail,
        parameters: {"code": code},
        retry: true,
      );
      if (response.statusCode == 200) {
        adventurerCardData =
            AdventurerCard.fromJson(jsonDecode(response.bodyUTF));
      } else if(response.statusCode >= 500 && response.statusCode < 600){
        errorMsg = "Server connect failed";
      }
      else {
        errorMsg = "adventurer card.verification failed";
      }
    } catch (e) {
      errorMsg = "Server connect failed";
      developer.log("Server connect failed.\n$e");
    }
    notifyListeners();
  }

  Future<String> saveImage() async {
    if (adventurerCardData == null) return "";
    final RenderRepaintBoundary boundary =
    imageKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage();
    final ByteData? byteData =
    await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    FileSaver().saveImage(
      pngBytes,
      "${adventurerCardData!.verificationCode}.png",
    );
    return "${adventurerCardData!.verificationCode}.png";
  }
}
