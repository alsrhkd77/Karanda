import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DefaultAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: InkWell(
        child: Text('Karanda', style: GoogleFonts.sourceCodePro(fontSize: 25.0),),
        hoverColor: Colors.transparent,
        onTap: () {
          Get.offAllNamed('/');
        },
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}

