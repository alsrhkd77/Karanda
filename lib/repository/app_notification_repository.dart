import 'dart:convert';

import 'package:karanda/data_source/web_socket_manager.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/app_notification_message.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class AppNotificationRepository {
  final WebSocketManager _webSocketManager;
  final _notification = BehaviorSubject<AppNotificationMessage>();

  AppNotificationRepository({required WebSocketManager webSocketManager})
      : _webSocketManager = webSocketManager;

  Stream<AppNotificationMessage> get notificationMessageStream =>
      _notification.stream;

  void addNotification(AppNotificationMessage message) {
    _notification.sink.add(message);
  }

  void connectNotificationChannel(BDORegion region) {
    _webSocketManager.register(
      destination: "/REGION/notification",
      callback: _onMessage,
      region: region,
    );
  }

  void connectPrivateNotificationChannel() {
    _webSocketManager.register(
      destination: "/user-private/notification/private",
      callback: _onMessage,
    );
  }

  void disconnectNotificationChannel() {
    _webSocketManager.unregister(destination: "/REGION/notification");
  }

  void disconnectPrivateNotificationChannel() {
    _webSocketManager.unregister(
      destination: "/user-private/notification/private",
    );
  }

  void _onMessage(StompFrame frame) {
    if (frame.body?.isNotEmpty ?? false) {
      final json = jsonDecode(frame.body!);
      _notification.sink.add(AppNotificationMessage.fromJson(json));
    }
  }
}
