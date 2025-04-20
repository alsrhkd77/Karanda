import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:karanda/model/app_notification_message.dart';
import 'package:karanda/repository/app_notification_repository.dart';
import 'package:karanda/repository/audio_player_repository.dart';
import 'package:karanda/repository/overlay_repository.dart';
import 'package:karanda/ui/core/theme/app_theme.dart';
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/snack_bar_content.dart';

import '../enums/features.dart';

class AppNotificationService {
  final AppNotificationRepository _appNotificationRepository;
  final AudioPlayerRepository _audioPlayerRepository;
  final OverlayRepository _overlayRepository;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  AppNotificationService({
    required AppNotificationRepository appNotificationRepository,
    required AudioPlayerRepository audioPlayerRepository,
    required OverlayRepository overlayRepository,
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  })  : _appNotificationRepository = appNotificationRepository,
        _audioPlayerRepository = audioPlayerRepository,
        _overlayRepository = overlayRepository,
        _scaffoldMessengerKey = scaffoldMessengerKey {
    _appNotificationRepository.notificationMessageStream.listen(_notify);
    if(kIsWeb){
      FirebaseMessaging.onMessage.listen(_onFCM);
    }
  }

  void _notify(AppNotificationMessage message) {
    if (_scaffoldMessengerKey.currentState != null) {
      final context = _scaffoldMessengerKey.currentState!.context;
      final width = MediaQuery.sizeOf(context).width;
      _scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
        duration: AppTheme.snackBarDuration,
        content: SnackBarContent(data: message),
        margin: Dimens.snackBarMargin(width),
        onVisible: () => _audioPlayerRepository.playNotificationSound(),
      ));
      _overlayRepository.sendToOverlay(
        method: "notification",
        data: jsonEncode(message.toJson()),
      );
    }
  }

  void _onFCM(RemoteMessage message) {
    if (message.notification != null) {
      if (kIsWeb) {
        _appNotificationRepository.addNotification(AppNotificationMessage(
          feature: Features.worldBoss,
          content: message.notification!.title!,
          mdContents: false,
        ));
      }
    }
  }
}
