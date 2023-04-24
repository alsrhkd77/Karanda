import 'dart:convert';

import 'package:http/http.dart' as http;

/*
* http.Response custom extension
 */
extension HttpResponseExtension on http.Response {
  String get bodyUTF => utf8.decode(bodyBytes);
}
