extension DurationExtension on Duration {
  String splitString(){
    return toString().split('.').first;
  }
}