import 'package:rxdart/rxdart.dart';
import 'package:web/web.dart';

abstract class WebVisibilityPlatform {
  final _streamController = BehaviorSubject<bool>.seeded(true);
  Stream<bool> get debouncedStatusStream => _streamController.stream.debounceTime(const Duration(seconds: 3));
  Stream<bool> get statusStream => _streamController.stream;
  bool get isVisible => _streamController.value;
  WebVisibilityPlatform(){
    document.onVisibilityChange.listen((event){
      if(document.visibilityState == "visible"){
        _streamController.sink.add(true);
      } else if(document.visibilityState == "hidden"){
        _streamController.sink.add(false);
      }
    });
  }
}