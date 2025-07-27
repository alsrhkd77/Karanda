import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/shutdown_scheduler/controller/shutdown_scheduler_controller.dart';
import 'package:provider/provider.dart';

class ShutdownSchedulerPage extends StatelessWidget {
  const ShutdownSchedulerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ShutdownSchedulerController(
        timeRepository: context.read(),
      ),
      builder: (context, child) {
        return Scaffold(
          appBar: KarandaAppBar(
            icon: FontAwesomeIcons.powerOff,
            title: context.tr("shutdownScheduler.shutdownScheduler"),
          ),
          body: Consumer(
            builder: (context, ShutdownSchedulerController controller, child) {
              if (controller.scheduled == null) {
                return LoadingIndicator();
              }
              final size = MediaQuery.sizeOf(context);
              return Container(
                padding: Dimens.pagePadding,
                alignment: Alignment.center,
                constraints: BoxConstraints(maxWidth: 1440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    _Contents(
                      width: size.width,
                      height: size.height,
                      scheduled: controller.scheduled ?? false,
                      target: controller.target,
                      now: controller.now,
                      onSelect: controller.setTarget,
                    ),
                    _Button(
                      width: size.width,
                      scheduled: controller.scheduled ?? false,
                      start: controller.setSchedule,
                      cancel: controller.cancelSchedule,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _Contents extends StatelessWidget {
  final double width;
  final double height;
  final bool scheduled;
  final DateTime target;
  final DateTime now;
  final void Function(TimeOfDay) onSelect;

  const _Contents({
    super.key,
    required this.width,
    required this.height,
    required this.scheduled,
    required this.target,
    required this.now,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.toStringWithSeparator();
    return SizedBox(
      width: width / 2,
      height: height / 2,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: scheduled
              ? null
              : () async {
                  TimeOfDay? selected = await showTimePicker(
                    context: context,
                    helpText: context.tr("shutdownScheduler.shutdownScheduler"),
                    initialTime: TimeOfDay.fromDateTime(target),
                  );
                  if (selected != null) {
                    onSelect(selected);
                  }
                },
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: width / 15,
                ),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    scheduled
                        ? target.difference(now).toString().split('.').first
                        : DateFormat.jm(locale).format(target),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                top: 15.0,
                right: 15.0,
                child: _Badge(
                  scheduled: scheduled,
                  target: target,
                  locale: locale,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String locale;
  final bool scheduled;
  final DateTime target;

  const _Badge({
    super.key,
    required this.locale,
    required this.scheduled,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    if (scheduled) {
      return Row(
        children: [
          Text(DateFormat.jm(locale).format(target)),
          Container(
            width: 28.0,
            height: 28.0,
            margin: EdgeInsets.symmetric(horizontal: 6.0),
            child: CircularProgressIndicator(),
          ),
        ],
      );
    }
    return const Icon(FontAwesomeIcons.clock);
  }
}

class _Button extends StatelessWidget {
  final double width;
  final bool scheduled;
  final void Function() start;
  final void Function() cancel;

  const _Button({
    super.key,
    required this.width,
    required this.scheduled,
    required this.start,
    required this.cancel,
  });

  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    );
    return SizedBox(
      width: width / 2,
      height: 40,
      child: ElevatedButton(
        onPressed: scheduled ? cancel : start,
        style: scheduled ? style : null,
        child: Text(
          context.tr("shutdownScheduler.${scheduled ? "cancel" : "start"}"),
        ),
      ),
    );
  }
}
