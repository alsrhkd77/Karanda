import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karanda/ui/windows_initializer/controllers/windows_initializer_controller.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class WindowsInitializerPage extends StatelessWidget {
  const WindowsInitializerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WindowsInitializerController(
        initializerService: context.read(),
        versionRepository: context.read(),
      ),
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ListTile(
              title: Text("Karanda", style: GoogleFonts.dongle(fontSize: 34)),
              trailing: const _Version(),
            ),
            Image.asset(
              'assets/brand/karanda_shape.png',
              width: 200,
              height: 200,
              filterQuality: FilterQuality.high,
            ),
            const _Progress(),
          ],
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.watch<WindowsInitializerController>().status;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.tr("initializer.${status.message}")),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LinearPercentIndicator(
              animation: true,
              progressColor: Colors.blue.shade400,
              animationDuration: 500,
              percent: status.progress,
              barRadius: const Radius.circular(12.0),
              animateFromLastPercent: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _Version extends StatelessWidget {
  const _Version({super.key});

  @override
  Widget build(BuildContext context) {
    final version = context.select<WindowsInitializerController, String>(
        (controller) => controller.version);
    return Text(
      version,
      style: TextTheme.of(context)
          .labelMedium
          ?.copyWith(color: Colors.grey.shade600),
    );
  }
}
