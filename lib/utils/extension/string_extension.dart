import 'package:intl/intl.dart';

extension StringExtension on String {
  String keepWord() {
    final RegExp emoji = RegExp(
        r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');
    List<String> words = split(' ');
    for (int i = 0; i < words.length; i++) {
      if (!emoji.hasMatch(words[i])) {
        words[i] = words[i]
            .replaceAllMapped(RegExp(r'(\S)(?=\S)'), (m) => '${m[1]}\u200D');
      }
    }
    return words.join(' ');
  }
}
