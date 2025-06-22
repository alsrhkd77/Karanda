import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/enums/recruitment_category.dart';
import 'package:karanda/model/app_notification_message.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/repository/party_finder_repository.dart';
import 'package:karanda/repository/app_notification_repository.dart';
import 'package:karanda/repository/app_settings_repository.dart';
import 'package:karanda/repository/audio_player_repository.dart';
import 'package:karanda/repository/auth_repository.dart';
import 'package:karanda/repository/overlay_repository.dart';
import 'package:karanda/ui/core/theme/app_theme.dart';
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/snack_bar_content.dart';

import '../enums/features.dart';
import 'dart:developer' as developer;

class AppNotificationService {
  final AppNotificationRepository _appNotificationRepository;
  final AudioPlayerRepository _audioPlayerRepository;
  final OverlayRepository _overlayRepository;
  final AppSettingsRepository _appSettingsRepository;
  final AuthRepository _authRepository;
  final PartyFinderRepository _partyFinderRepository;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  AppNotificationService({
    required AppNotificationRepository appNotificationRepository,
    required AudioPlayerRepository audioPlayerRepository,
    required OverlayRepository overlayRepository,
    required AppSettingsRepository appSettingsRepository,
    required AuthRepository authRepository,
    required PartyFinderRepository partyFinderRepository,
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  })  : _appNotificationRepository = appNotificationRepository,
        _audioPlayerRepository = audioPlayerRepository,
        _overlayRepository = overlayRepository,
        _appSettingsRepository = appSettingsRepository,
        _authRepository = authRepository,
        _partyFinderRepository = partyFinderRepository,
        _scaffoldMessengerKey = scaffoldMessengerKey {
    _appNotificationRepository.notificationMessageStream
        .where(_filter)
        .listen(_notify);
    if (kIsWeb || Platform.isAndroid) {
      FirebaseMessaging.onMessage.listen(_onFCM);
    } else if (Platform.isWindows) {
      _appSettingsRepository.settingsStream
          .map((value) => value.region)
          .distinct()
          .listen(connectNotificationChannel);
      _authRepository.userStream.distinct().listen(_onUserUpdate);
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

  bool _filter(AppNotificationMessage message) {
    try {
      if (!kIsWeb && message.feature == Features.partyFinder) {
        final partyFinderSettings = _partyFinderRepository.settings;
        final category = RecruitmentCategory.values
            .byName(message.contentsKey.split(" ").first);
        if (!partyFinderSettings.notify) {
          return false;
        } else if (partyFinderSettings.excludedCategory.contains(category)) {
          return false;
        }
      }
    } catch (e) {
      developer.log("Exception from NotificationMessage filter\n$e");
    }
    return true;
  }

  void _onFCM(RemoteMessage message) {
    if (message.notification != null) {
      if (kIsWeb) {
        _appNotificationRepository
            .addNotification(AppNotificationMessage.fromRemoteMessage(message));
      }
    }
  }

  void connectNotificationChannel(BDORegion region) {
    _appNotificationRepository.disconnectNotificationChannel();
    _appNotificationRepository.connectNotificationChannel(region);
  }

  void _onUserUpdate(User? value) {
    _appNotificationRepository.disconnectPrivateNotificationChannel();
    if (value != null) {
      _appNotificationRepository.connectPrivateNotificationChannel();
    }
  }
}
