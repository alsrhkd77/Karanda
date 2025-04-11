import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/foundation.dart';

class TokenUtils {
  static const String _issuer = 'https://www.karanda.kr/client';
  static final Map<String, String> _payload = {
    'platform': kIsWeb ? 'WEB' : 'WINDOWS',
  };
  //TODO: use offset

  static String serviceToken(){
    DateTime now = DateTime.now();
    int stamp = (now.toUtc().millisecondsSinceEpoch ~/ 600000);
    _payload['stamp'] = stamp.toString(); //not used
    final jwt = JWT(
      _payload,
      issuer: _issuer
    );
    String secret = const String.fromEnvironment('SECRET');
    if(secret.isEmpty) return '';
    String token = jwt.sign(SecretKey(secret));
    return token;
  }
}