import 'dart:ui';

class MonitorDevice {
  String name;
  String deviceID;
  Rect rect;

  MonitorDevice({
    required this.name,
    required this.deviceID,
    required this.rect,
  });

  factory MonitorDevice.fromJson(Map json) {
    return MonitorDevice(
      name: json["name"],
      deviceID: json["deviceID"],
      rect: Rect.fromLTWH(
        json["left"],
        json["top"],
        json["width"],
        json["height"],
      ),
    );
  }

  Map toJson() {
    return {
      "name": name,
      "deviceID": deviceID,
      "left": rect.left,
      "top": rect.top,
      "width": rect.width,
      "height": rect.height,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is MonitorDevice &&
        runtimeType == other.runtimeType &&
        deviceID == other.deviceID &&
        rect == other.rect;
  }

  @override
  int get hashCode => Object.hash(deviceID, rect);

  @override
  String toString() {
    return "ID: $deviceID, name: $name, rect: ${rect.toString()}";
  }
}
