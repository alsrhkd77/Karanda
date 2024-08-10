import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karanda/common/bdo_world_time_notifier.dart';
import 'package:karanda/common/time_of_day_extension.dart';
import 'package:provider/provider.dart';

class BdoClock extends StatelessWidget {
  const BdoClock({super.key});

  @override
  Widget build(BuildContext context) {
    final TimeOfDay time = context
        .select<BdoWorldTimeNotifier, TimeOfDay>((value) => value.bdoTime);
    IconData icon = FontAwesomeIcons.solidSun;
    if (time.hour >= 22 || time.hour < 7) {
      icon = FontAwesomeIcons.solidMoon;
    }
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.yellow.shade400,
        ),
        const SizedBox(
          width: 6,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 3.0, 0, 0),
          child: Text(
            time.timeWithPeriod(),
            style: GoogleFonts.dongle(fontSize: 28.0),
          ),
        ),
      ],
    );
  }
}
