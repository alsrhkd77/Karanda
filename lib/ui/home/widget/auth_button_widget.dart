import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/service/auth_service.dart';
import 'package:karanda/ui/core/ui/button_loading_indicator.dart';
import 'package:karanda/ui/home/controller/auth_button_controller.dart';
import 'package:provider/provider.dart';

class AuthButtonWidget extends StatelessWidget {
  const AuthButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<AuthService, AuthButtonController>(
      create: (context) => AuthButtonController(
        authService: context.read(),
        router: GoRouter.of(context),
      ),
      update: (context, service, controller) {
        controller?.update();
        return controller ??
            AuthButtonController(
              authService: context.read(),
              router: GoRouter.of(context),
            );
      },
      child: Consumer(
        builder: (context, AuthButtonController controller, child) {
          if (controller.waitResponse) {
            return const _Button(
              onPressed: null,
              label: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                child: ButtonLoadingIndicator(
                  size: 16,
                ),
              ),
            );
          } else if (controller.user != null) {
            return _Button(
              icon: CircleAvatar(
                foregroundImage: Image.network(controller.user!.avatar).image,
                radius: 12,
              ),
              label: Text(controller.user!.username),
              onPressed: controller.onClick,
            );
          }
          return _Button(
            icon: const Icon(Icons.account_circle_outlined),
            label: Text(context.tr("auth.login")),
            onPressed: controller.onClick,
          );
        },
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final Widget? icon;
  final Widget label;
  final void Function()? onPressed;

  const _Button({super.key, this.icon, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    /*return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        child: Row(
          children: [
            icon == null ? SizedBox() : Padding(
              padding: const EdgeInsets.all(2.0),
              child: icon!,
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: label,
            )
          ],
        ),
      ),
    );*/
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 15.0),
      ),
      onPressed: onPressed,
      label: label,
      icon: icon,
    );
  }
}
