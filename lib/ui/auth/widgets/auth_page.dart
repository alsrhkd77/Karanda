import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/ui/auth/controllers/auth_controller.dart';
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KarandaAppBar(
        icon: Icons.account_circle_outlined,
        title: context.tr("auth.social login"),
      ),
      body: SingleChildScrollView(
        padding: Dimens.pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Dimens.pageMaxWidth),
            child: Column(
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: AuthController(authService: context.read())
                        .authentication,
                    child: Image.asset(
                      "assets/image/discord_full.png",
                      isAntiAlias: true,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
