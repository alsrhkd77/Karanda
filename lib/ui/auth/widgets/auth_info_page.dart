import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/model/user.dart';
import 'package:karanda/ui/auth/controllers/auth_controller.dart';
import 'package:karanda/ui/auth/widgets/family_info.dart';
import 'package:karanda/ui/core/theme/app_colors.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/core/ui/section.dart';
import 'package:provider/provider.dart';

import 'unregister_dialog.dart';

class AuthInfoPage extends StatelessWidget {
  const AuthInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KarandaAppBar(
        icon: Icons.account_circle_outlined,
        title: context.tr("auth.accountInfo"),
      ),
      body: ChangeNotifierProvider(
        create: (context) => AuthController(authService: context.read()),
        child: Consumer(
          builder: (context, AuthController controller, child) {
            if (controller.user == null) {
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
              Section(
                icon: Icons.groups,
                title: context.tr("family.family"),
                child: FamilyInfo(
                  family: controller.user?.family,
                  register: controller.registerFamily,
                  update: controller.updateFamilyData,
                  unregister: controller.unregisterFamily,
                ),
              ),
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
          trailing: Text(user.username),
        ),
        ListTile(
          title: Text(context.tr("auth.platform")),
          trailing: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(
                  FontAwesomeIcons.discord,
                  color: AppColors.discordPrimary,
                ),
              ),
              Text("Discord"),
            ],
          ),
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
          backgroundImage: Image.network(user.avatar).image,
          radius: width / 2,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
