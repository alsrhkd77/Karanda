extension DurationExtension on Duration {

  /* return HH:mm:ss */
  String toHMS(){
    String base = '';
    String h = '';
    String m = '';
    String s = '';
    if(isNegative){
      h = inHours.toString().replaceAll('-', '');
      m = (inMinutes % 60).toString();
      s = (60 -(inSeconds % 60)).toString();
      base = '-';
    } else {
      h = inHours.toString();
      m = (inMinutes % 60).toString();
      s = (inSeconds % 60).toString();
    }
    return '$base${h.padLeft(2,'0')}:${m.padLeft(2,'0')}:${s.padLeft(2,'0')}';
  }
}