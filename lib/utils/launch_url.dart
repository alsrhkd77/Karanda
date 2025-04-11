import 'package:flutter/material.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:url_launcher/url_launcher.dart';

void launchURL(String url, {bool newTab = true}) async {
  Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, webOnlyWindowName: newTab ? '_blank' : '_self')) {
    throw ScaffoldMessengerState().showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text('해당 링크를 열 수 없습니다. \n $uri '),
      margin: GlobalProperties.snackBarMargin,
    ));
  }
}