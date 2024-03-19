import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/foundation.dart';

class TokenFactory {
  static const String _issuer = 'Karanda';
  static final Map<String, String> _payload = {
    'platform': kIsWeb ? 'WEB' : 'WINDOWS',
  };

  static String serviceToken(){
    DateTime now = DateTime.now();
    int stamp = (now.toUtc().millisecondsSinceEpoch / 600000).floor();
    _payload['stamp'] = stamp.toString();
    final jwt = JWT(
      _payload,
      issuer: _issuer
    );
    String secret = const String.fromEnvironment('SECRET');
    String token = jwt.sign(SecretKey(secret));
    return token;
  }
}