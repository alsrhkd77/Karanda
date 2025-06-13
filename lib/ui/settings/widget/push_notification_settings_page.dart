import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/loading_indicator_dialog.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/core/ui/section.dart';
import 'package:karanda/ui/settings/controller/user_fcm_settings_controller.dart';
import 'package:provider/provider.dart';

class PushNotificationSettingsPage extends StatelessWidget {
  const PushNotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserFcmSettingsController(
        appSettingsService: context.read(),
      )..loadData(),
      child: Scaffold(
        appBar: KarandaAppBar(
          icon: Icons.notifications,
          title: context.tr("settings.push notifications"),
        ),
        body: Consumer(
          builder: (context, UserFcmSettingsController controller, child) {
            if (!controller.initialized) {
              return const LoadingIndicator();
            }
            return PageBase(children: [
              _ActivationSwitchingTile(
                status: controller.activate,
                activatePushNotifications: controller.activatePushNotifications,
                deactivatePushNotifications:
                    controller.deactivatePushNotifications,
              ),
              Section(
                title: "Features",
                child: Column(
                  children: [
                    CheckboxListTile(
                      enabled: controller.activate,
                      title: Text(context.tr("adventurer hub.adventurer hub")),
                      value: controller.fcmSettings?.adventurerHub ?? false,
                      onChanged: controller.switchAdventurerHubStatus,
                    ),
                  ],
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }
}

class _ActivationSwitchingTile extends StatefulWidget {
  final bool status;
  final Future<bool> Function() activatePushNotifications;
  final Future<void> Function() deactivatePushNotifications;

  const _ActivationSwitchingTile({
    super.key,
    required this.status,
    required this.activatePushNotifications,
    required this.deactivatePushNotifications,
  });

  @override
  State<_ActivationSwitchingTile> createState() =>
      _ActivationSwitchingTileState();
}

class _ActivationSwitchingTileState extends State<_ActivationSwitchingTile> {
  Future<void> activatePushNotifications() async {
    final agree = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr("settings.activate push notifications")),
        content: Text(
          context.tr("settings.push notifications activation notice"),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            ),
            child: Text(context.tr("cancel")),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(context.tr("confirm")),
          )
        ],
      ),
    );
    if (agree != null && agree) {
      showLoadingDialog();
      final result = await widget.activatePushNotifications();
      if (mounted) {
        Navigator.of(context).pop();
        if (!result) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.tr("settings.activate push notifications fail"),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> deactivatePushNotifications() async {
    showLoadingDialog();
    await widget.deactivatePushNotifications();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void showLoadingDialog() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => const LoadingIndicatorDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: widget.status,
      onChanged: (value) {
        if (value) {
          activatePushNotifications();
        } else {
          deactivatePushNotifications();
        }
      },
      title: Text(context.tr("settings.activate push notifications")),
    );
  }
}
