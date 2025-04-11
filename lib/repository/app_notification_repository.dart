import 'package:karanda/model/app_notification_message.dart';
import 'package:rxdart/rxdart.dart';

class AppNotificationRepository {
  final _notification = BehaviorSubject<AppNotificationMessage>();

  Stream<AppNotificationMessage> get notificationMessageStream =>
      _notification.stream;

  void addNotification(AppNotificationMessage message) {
    _notification.sink.add(message);
  }
}
