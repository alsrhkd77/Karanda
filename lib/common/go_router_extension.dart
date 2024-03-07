import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/common/analytics/karanda_analytics.dart'
    if (dart.library.io) 'package:karanda/common/analytics/windows_analytics.dart'
    if (dart.library.js_interop) 'package:karanda/common/analytics/web_analytics.dart';

extension GoRouterExtension on GoRouter {
  void goWithGa(String location, {Object? extra}) {
    pageTransition(location);
    go(location, extra: extra);
  }
}

extension GoRouterHelperExtension on BuildContext {
  void goWithGa(String location, {Object? extra}) {
    pageTransition(location);
    GoRouter.of(this).go(location, extra: extra);
  }
}
