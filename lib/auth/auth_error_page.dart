import 'package:flutter/material.dart';
import 'package:karanda/common/go_router_extension.dart';
import 'package:karanda/widgets/default_app_bar.dart';

class AuthErrorPage extends StatelessWidget {
  const AuthErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(24.0),
              child: const Icon(Icons.lock_person, size: 150.0, color: Colors.red,),
            ),
            Container(
              margin: const EdgeInsets.all(24.0),
              alignment: Alignment.center,
              child: const Text(
                '사용자 인증에 실패했습니다',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(24.0),
              alignment: Alignment.center,
              child: const Text(
                '잠시 후 다시 시도하거나 관리자에게 문의해주세요',
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                context.goWithGa('/');
              },
              icon: const Icon(Icons.home),
              label: Container(
                margin: const EdgeInsets.all(12.0),
                child: const Text('Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
