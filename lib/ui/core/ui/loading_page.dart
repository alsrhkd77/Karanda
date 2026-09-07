import 'package:flutter/material.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';

/// 앱바를 유지한 채 로딩을 표시하는 페이지.
///
/// 앱바 없이 인디케이터만 필요한 경우에는 [LoadingIndicatorPage]를 사용한다.
class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: KarandaAppBar(),
      body: Center(
        child: LoadingIndicator(),
      ),
    );
  }
}
