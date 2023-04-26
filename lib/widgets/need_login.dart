import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NeedLogin extends StatelessWidget {
  const NeedLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(24.0),
            child: const Icon(Icons.lock_person, size: 150.0),
          ),
          Container(
            margin: const EdgeInsets.all(24.0),
            alignment: Alignment.center,
            child: const Text(
              '로그인이 필요한 서비스입니다',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              overflow: TextOverflow.clip,
              textAlign: TextAlign.center,
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Get.toNamed('/auth/authenticate');
            },
            icon: const Icon(Icons.login),
            label: Container(
              margin: const EdgeInsets.all(12.0),
              child: const Text('Social login'),
            ),
          ),
        ],
      ),
    );
  }
}
