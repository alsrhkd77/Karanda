import 'dart:io';

void addListener({required Function onVisible, required Function onHidden}) =>
    throw UnsupportedError(
        'Platform not supported! Current platform is ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');

bool? currentVisible() => throw UnsupportedError(
    'Platform not supported! Current platform is ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
