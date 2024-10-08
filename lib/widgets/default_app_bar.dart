import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karanda/common/go_router_extension.dart';
import 'package:karanda/widgets/bdo_clock.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget? bottom;

  const DefaultAppBar({Key? key, this.bottom}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      actions: const [
        Padding(
          padding: EdgeInsets.fromLTRB(0.0, 4.0, 18.0, 0),
          child: BdoClock(),
        ),
      ],
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
