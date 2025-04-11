abstract class WebVisibilityPlatform {
  Stream<bool> get debouncedStatusStream => throw UnsupportedError('Platform unsupported.');
  Stream<bool> get statusStream => throw UnsupportedError('Platform unsupported.');
  bool get isVisible => throw UnsupportedError('Platform unsupported.');
}