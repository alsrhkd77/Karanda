import 'dart:developer' as developer;

import 'dart:js_interop';

@JS()
external void sendNavigation(String location);

void pageTransition(String location) {
  if (!location.startsWith('/')) location = '/$location';
  developer.log(location, name: 'page transition');
  sendNavigation(location);
}
