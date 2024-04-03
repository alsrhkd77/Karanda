import 'dart:html';

void addListener({required Function onVisible, required Function onHidden}) {
  document.onVisibilityChange.listen((event) {
    switch (document.visibilityState) {
      case "visible":
        onVisible();
        break;
      case "hidden":
        onHidden();
        break;
    }
  });
}

bool? currentVisible(){
  switch (document.visibilityState) {
    case "visible":
      return true;
    case "hidden":
      return false;
    default:
      return null;
  }
}
