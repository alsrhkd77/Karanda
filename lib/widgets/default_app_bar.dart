import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karanda/common/go_router_extension.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget? bottom;
  final String? title;
  final IconData? icon;
  final List<Widget>? actions;

  const DefaultAppBar({Key? key, this.bottom, this.title, this.icon, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(title == null){
      return AppBar(
        centerTitle: true,
        title: InkWell(
          hoverColor: Colors.transparent,
          onTap: () {
            context.goWithGa('/');
          },
          child: Text(
            'Karanda',
            style: GoogleFonts.dongle(fontSize: 46),
          ),
        ),
        actions: actions,
        bottom: bottom,
      );
    }
    return AppBar(
      title: icon == null ? Text(title ?? "Karanda") : Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12,),
          Text(title ?? "Karanda")
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
