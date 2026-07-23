/// 미러링 소스 후보 창 정보 (세션 한정, 영속화하지 않음)
class WindowInfo {
  final int handle;
  final String title;

  const WindowInfo({required this.handle, required this.title});

  @override
  bool operator ==(Object other) =>
      other is WindowInfo && other.handle == handle;

  @override
  int get hashCode => handle.hashCode;
}
