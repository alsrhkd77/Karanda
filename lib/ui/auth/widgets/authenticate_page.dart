import 'package:flutter/material.dart';
import 'package:karanda/service/auth_service.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class AuthenticatePage extends StatefulWidget {
  final String token;
  final String refreshToken;

  const AuthenticatePage({
    super.key,
    required this.token,
    required this.refreshToken,
  });

  @override
  State<AuthenticatePage> createState() => _AuthenticatePageState();
}

class _AuthenticatePageState extends State<AuthenticatePage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthService>().processingTokens(
          widget.token,
          widget.refreshToken,
        );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LoadingIndicator(),
    );
  }
}
