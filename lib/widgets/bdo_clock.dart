import 'package:flutter/material.dart';
import 'package:karanda/common/bdo_world_time_notifier.dart';
import 'package:karanda/common/time_of_day_extension.dart';
import 'package:provider/provider.dart';

class BdoClock extends StatelessWidget {
  const BdoClock({super.key});

  @override
  Widget build(BuildContext context) {
    final TimeOfDay time = context
        .select<BdoWorldTimeNotifier, TimeOfDay>((value) => value.bdoTime);
    String icon = 'assets/icons/sun.png';
    if (time.hour >= 22 || time.hour < 7) {
      icon = 'assets/icons/moon.png';
    }
    return Row(
      children: [
        Image.asset(
          icon,
          height: 24,
          width: 24,
        ),
        const SizedBox(
          width: 6,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 3.0, 0, 0),
          child: Text(time.timeWithPeriod(),
              style: const TextStyle(
                  fontFamily: 'NanumSquareRound',
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
