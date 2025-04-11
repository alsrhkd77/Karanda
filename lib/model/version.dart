class Version {
  final int major;
  final int minor;
  final int patch;
  final String text;

  Version({
    required this.major,
    required this.minor,
    required this.patch,
    required this.text,
  });

  factory Version.fromString(String value) {
    final v = value.split(".");
    return Version(
      major: int.parse(v.first),
      minor: int.parse(v[1]),
      patch: int.parse(v.last),
      text: value,
    );
  }

  /// `this`가 [other]보다 최신이거나 같으면 `true`를 반환
  bool isNewerThan(Version other) {
    if(text == other.text){
      return true;
    } else if (major != other.major) {
      return major > other.major;
    } else if (minor != other.minor) {
      return minor > other.minor;
    }
    return patch > other.patch;
  }

  @override
  String toString() {
    return text;
  }
}
