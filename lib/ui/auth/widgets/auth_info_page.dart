import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/model/bdo_family.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/ui/auth/controllers/auth_controller.dart';
import 'package:karanda/ui/core/theme/app_colors.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/core/ui/section.dart';
import 'package:provider/provider.dart';

class AuthInfoPage extends StatelessWidget {
  const AuthInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KarandaAppBar(
        icon: Icons.account_circle_outlined,
        title: context.tr("auth.account info"),
      ),
      body: ChangeNotifierProvider(
        create: (context) => AuthController(authService: context.read()),
        child: Consumer(
          builder: (context, AuthController controller, child) {
            if(controller.user == null){
              return const LoadingIndicator();
            }
            final width = MediaQuery.sizeOf(context).width;
            return PageBase(children: [
              _ProfileImage(
                user: controller.user!,
                width: min(width * 0.5, 140),
              ),
              Section(
                icon: Icons.account_box,
                title: context.tr("auth.account"),
                child: _Account(user: controller.user!),
              ),
              /*Section(
                icon: Icons.groups,
                title: context.tr("auth.family"),
                child: _Family(families: controller.families, addFamily: () {}),
              ),*/
              Section(
                icon: Icons.manage_accounts,
                title: context.tr("auth.management"),
                child: Column(
                  children: [
                    ListTile(
                      onTap: controller.logout,
                      textColor: Colors.orange,
                      iconColor: Colors.orange,
                      title: Text(context.tr("auth.logout")),
                      trailing: const Icon(Icons.logout),
                    ),
                    ListTile(
                      onTap: () async {
                        controller.unregister(await showDialog<bool>(
                          context: context,
                          builder: (context) => const UnregisterDialog(),
                        ));
                      },
                      textColor: Colors.red,
                      iconColor: Colors.red,
                      title: Text(context.tr("auth.unregister")),
                      trailing: const Icon(Icons.no_accounts),
                    )
                  ],
                ),
              )
            ]);
          },
        ),
      ),
    );
  }
}

class _Account extends StatelessWidget {
  final User user;

  const _Account({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(context.tr("auth.username")),
          trailing: Text(user.username, style: TextTheme.of(context).bodyLarge),
        ),
        ListTile(
          title: Text(context.tr("auth.platform")),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(
                  FontAwesomeIcons.discord,
                  color: AppColors.discordPrimary,
                ),
              ),
              Text("Discord", style: TextTheme.of(context).bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}

class _Family extends StatelessWidget {
  final List<BDOFamily> families;
  final void Function() addFamily;

  const _Family({super.key, required this.families, required this.addFamily});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...families.map(
              (family) => ListTile(title: Text(family.familyName)),
        ),
        ListTile(
          onTap: () {},
          leading: const Icon(Icons.add),
          title: Text(context.tr("auth.add family")),
        ),
      ],
    );
  }
}

class _ProfileImage extends StatelessWidget {
  final User user;
  final double width;

  const _ProfileImage({super.key, required this.width, required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundImage:
          Image.network(user.avatar).image,
          radius: width / 2,
        ),
      ),
    );
  }
}

class UnregisterDialog extends StatefulWidget {
  const UnregisterDialog({super.key});

  @override
  State<UnregisterDialog> createState() => _UnregisterDialogState();
}

class _UnregisterDialogState extends State<UnregisterDialog> {
  final formKey = GlobalKey<FormState>();
  final String targetText = 'UNREGISTER';

  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return context.tr("validator.empty");
    } else if (value != targetText) {
      return context.tr("validator.fillWith", args: ["'$targetText'"]);
    }
    return null;
  }

  void confirm() {
    if (formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr("auth.unregister")),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: formKey,
            child: TextFormField(
              maxLines: 1,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                hintText: targetText,
              ),
              validator: validator,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr("cancel")),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: confirm,
          child: Text(context.tr("confirm")),
        ),
      ],
    );
  }
}
