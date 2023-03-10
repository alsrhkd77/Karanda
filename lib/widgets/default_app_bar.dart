import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karanda/common/bdo_world_time_notifier.dart';
import 'package:karanda/common/time_of_day_extension.dart';
import 'package:provider/provider.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DefaultAppBar({Key? key}) : super(key: key);

  Widget bdoClock(TimeOfDay time) {
    String _icon = 'assets/icons/sun.png';
    if (time.hour >= 22 || time.hour < 7) {
      _icon = 'assets/icons/moon.png';
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 4.0, 18.0, 0),
      child: Row(
        children: [
          Image.asset(
            _icon,
            height: 22,
            width: 22,
            filterQuality: FilterQuality.low,
          ),
          const SizedBox(
            width: 6,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 3.0, 0, 0),
            child: Text(time.timeWithPeriod(),
                style:
                    const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BdoWorldTimeNotifier(),
      child: Consumer(
        builder: (context, BdoWorldTimeNotifier _bdoWorldTimeNotifier, _) {
          return AppBar(
            centerTitle: true,
            actions: [
              bdoClock(_bdoWorldTimeNotifier.bdoTime),
            ],
            title: InkWell(
              child: Text(
                'Karanda',
                style: GoogleFonts.sourceCodePro(fontSize: 26.0),
              ),
              hoverColor: Colors.transparent,
              onTap: () {
                Get.offAllNamed('/');
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}
