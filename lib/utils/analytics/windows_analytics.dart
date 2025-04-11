import 'dart:developer' as developer;

void pageTransition(String location) {
  if (!location.startsWith('/')) location = '/$location';
  developer.log(location, name: 'page transition');
}
