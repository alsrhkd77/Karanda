import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/bdo_family.dart';
import 'package:karanda/ui/auth/widgets/register_family_page.dart';
import 'package:karanda/ui/auth/widgets/unregister_dialog.dart';
import 'package:karanda/ui/core/controller/time_controller.dart';
import 'package:karanda/ui/core/ui/class_symbol_widget.dart';
import 'package:karanda/ui/core/ui/loading_indicator_dialog.dart';
import 'package:karanda/ui/core/ui/snack_bar_kit.dart';
import 'package:karanda/utils/extension/duration_extension.dart';
import 'package:provider/provider.dart';

import 'family_verification_page.dart';

class FamilyInfo extends StatefulWidget {
  final BDOFamily? family;
  final Future<bool> Function({
    required String code,
    required String familyName,
    required BDORegion region,
  }) register;
  final Future<bool> Function() update;
  final Future<bool> Function() unregister;

  const FamilyInfo({
    super.key,
    this.family,
    required this.register,
    required this.update,
    required this.unregister,
  });

  @override
  State<FamilyInfo> createState() => _FamilyInfoState();
}

class _FamilyInfoState extends State<FamilyInfo> {
  Future<void> update() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingIndicatorDialog(),
    );
    final result = await widget.update();
    if (mounted) {
      Navigator.of(context).pop();
      if (!result) {
        SnackBarKit.of(context).requestFailed();
      }
    }
  }

  Future<void> unregister() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingIndicatorDialog(),
    );
    final result = await widget.unregister();
    if (mounted) {
      Navigator.of(context).pop();
      if (!result) {
        SnackBarKit.of(context).requestFailed();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.family == null) {
      return ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  RegisterFamilyPage(register: widget.register),
            ),
          );
        },
        title: Text(context.tr("family.register")),
        trailing: const Icon(Icons.group_add_outlined),
      );
    }
    return Column(
      children: [
        ListTile(
          title: Text(context.tr("family.familyName")),
          trailing: Text(widget.family!.familyName),
        ),
        ListTile(
          title: Text(context.tr("family.mainClass")),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClassSymbolWidget(bdoClass: widget.family!.mainClass),
              Text(widget.family!.mainClass.name),
            ],
          ),
        ),
        ListTile(
          title: Text(context.tr("family.maxGearScore")),
          trailing: Text(widget.family?.maxGearScore?.toString() ?? "-"),
        ),
        ListTile(
          title: Text(context.tr("family.verificationStatus")),
          trailing: _Verified(value: widget.family?.verified ?? false),
        ),
        ListTile(
          title: Text(context.tr("family.lastUpdate")),
          trailing: Text(widget.family?.lastUpdated == null
              ? "-"
              : DateFormat.yMMMEd(context.locale.toStringWithSeparator())
                  .add_Hm()
                  .format(widget.family!.lastUpdated!)),
        ),
        widget.family!.verified
            ? _FamilyDataUpdateButton(
                onTap: update,
                lastUpdated: widget.family?.lastUpdated,
              )
            : ListTile(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const FamilyVerificationPage(),
                  ));
                },
                title: Text(context.tr("family.verify")),
                textColor: Colors.blue,
                iconColor: Colors.blue,
                trailing: const Icon(Icons.how_to_reg_outlined),
              ),
        ListTile(
          onTap: () async {
            final value = await showDialog<bool>(
              context: context,
              builder: (context) => const UnregisterDialog(),
            );
            if (value ?? false) {
              await unregister();
            }
          },
          title: Text(context.tr("family.unregister")),
          textColor: Colors.red,
          iconColor: Colors.red,
          trailing: const Icon(Icons.group_off_outlined),
        )
      ],
    );
  }
}

class _Verified extends StatelessWidget {
  final bool value;

  const _Verified({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.tr("family.${value ? "verified" : "unverified"}")),
        const SizedBox(
          width: 4,
        ),
        Icon(
          Icons.verified,
          color: value ? Colors.blue : Colors.grey,
        ),
      ],
    );
  }
}

class _FamilyDataUpdateButton extends StatelessWidget {
  final DateTime? lastUpdated;
  final void Function() onTap;

  const _FamilyDataUpdateButton({
    super.key,
    required this.onTap,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, TimeController controller, child) {
        final diff = lastUpdated
            ?.add(const Duration(minutes: 300))
            .difference(controller.local);
        return ListTile(
          enabled: diff?.isNegative ?? true,
          onTap: onTap,
          title: Text(context.tr("family.update")),
          textColor: Colors.blue,
          iconColor: Colors.blue,
          trailing: diff?.isNegative ?? true
              ? const Icon(Icons.sync)
              : Text(diff!.splitString()),
        );
      },
    );
  }
}
