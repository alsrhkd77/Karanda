import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class KarandaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget? bottom;
  final String? title;
  final IconData? icon;
  final List<Widget>? actions;

  const KarandaAppBar({
    Key? key,
    this.bottom,
    this.title,
    this.icon,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.dongle(fontSize: 46);
    if (title == null) {
      return AppBar(
        centerTitle: true,
        title: InkWell(
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            context.go('/');
          },
          child: Text('Karanda', style: style),
        ),
        actions: actions,
        bottom: bottom,
      );
    }
    return AppBar(
      title: icon == null
          ? Text(title!)
          : Row(
              children: [
                Icon(icon),
                const SizedBox(width: 12),
                Text(title!)
              ],
            ),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize {
    return bottom == null
        ? Size.fromHeight(AppBar().preferredSize.height)
        : Size.fromHeight(
            AppBar().preferredSize.height + bottom!.preferredSize.height);
  }
}
