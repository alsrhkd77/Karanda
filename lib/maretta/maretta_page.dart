import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/common/channel.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/common/real_time_notifier.dart';
import 'package:karanda/maretta/maretta_blacklist_dialog.dart';
import 'package:karanda/maretta/maretta_detail_dialog.dart';
import 'package:karanda/maretta/maretta_map_viewer.dart';
import 'package:karanda/maretta/maretta_model.dart';
import 'package:karanda/maretta/maretta_notifier.dart';
import 'package:karanda/maretta/maretta_report_dialog.dart';
import 'package:karanda/maretta/maretta_report_model.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/need_login_snack_bar.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class MarettaPage extends StatefulWidget {
  const MarettaPage({super.key});

  @override
  State<MarettaPage> createState() => _MarettaPageState();
}

class _MarettaPageState extends State<MarettaPage> with WindowListener {
  late MarettaNotifier _provider;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _provider = Provider.of<MarettaNotifier>(context, listen: false);
      //_provider.getReports();
      _provider.connect();
    });
  }

  @override
  void activate() {
    super.activate();
    _provider.connect();
  }

  @override
  void onWindowFocus() {
    _provider.connect();
  }


  @override
  void onWindowClose() {
    _provider.disconnect();
  }

  @override
  void deactivate() {
    _provider.disconnect();
    super.deactivate();
  }

  @override
  void dispose() {
    _provider.dispose();
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> report() async {
    if (context.read<AuthNotifier>().authenticated) {
      MarettaReportModel? item = await showDialog(
          context: context, builder: (_) => const MarettaReportDialog());
      if (item != null) {
        bool result = await context.read<MarettaNotifier>().createReport(item);
        if (!result) {
          showReportFailedSnackBar();
        }
      }
    } else {
      NeedLoginSnackBar(context);
    }
  }

  void showReportFailedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.redAccent,
            ),
            SizedBox(
              width: 8.0,
            ),
            Text('잠시 후 다시 시도해주세요.'),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: GlobalProperties.snackBarMargin,
        backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
      ),
    );
  }

  Future<void> showBlacklist() async {
    if (context.read<AuthNotifier>().authenticated) {
      await showDialog(
          context: context, builder: (_) => const MarettaBlacklistDialog());
    } else {
      NeedLoginSnackBar(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: const TitleText(
                '마레타 현황 (임시)',
                bold: true,
              ),
              leading: const Icon(FontAwesomeIcons.circleNodes),
              /*
              trailing: ElevatedButton(
                onPressed: showBlacklist,
                child: const Text('제외한 제보자'),
              ),
               */
              trailing: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (context, _, __) =>
                            const MarettaMapViewer(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 1.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;
                          final tween = Tween(begin: begin, end: end);
                          final curvedAnimation = CurvedAnimation(
                            parent: animation,
                            curve: curve,
                          );
                          return SlideTransition(
                            position: tween.animate(curvedAnimation),
                            child: child,
                          );
                        }),
                  );
                },
                icon: const Icon(FontAwesomeIcons.mapLocationDot),
                iconSize: 20,
              ),
            ),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: Channel.kr.keys
                  .map((e) => _ChannelCard(
                        channel: e,
                        item: Provider.of<MarettaNotifier>(context)
                                .reportList[e] ??
                            [],
                      ))
                  .toList(),
            ),
            const SizedBox(height: 15.0),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: report,
        icon: Transform.rotate(
            angle: -45 * pi / 180, child: const Icon(Icons.send)),
        label: const Text('제보하기'),
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final List<MarettaModel> item;
  final AllChannel channel;

  const _ChannelCard({super.key, required this.channel, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 280,
      ),
      child: Card(
        margin: const EdgeInsets.all(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                Channel.toKrServerName(channel),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ...List.generate(Channel.kr[channel]!,
                  (index) => _ChannelLine(item: item[index]))
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelLine extends StatelessWidget {
  final MarettaModel item;

  const _ChannelLine({super.key, required this.item});

  Future<void> showDetail(BuildContext context) async {
    bool? dialog = await showDialog(
      context: context,
      builder: (_) => MarettaDetailDialog(item: item),
    );
    if (dialog != null && dialog) {
      if (context.read<AuthNotifier>().authenticated) {
        context
            .read<MarettaNotifier>()
            .createBlacklist(item.report!.reporterDiscordId!);
      } else {
        NeedLoginSnackBar(context);
      }
    }
  }

  MarettaStatus getStatus(BuildContext context) {
    if (item.status == MarettaStatus.dead) {
      Duration diff = elapsed(context);
      if (diff.inMinutes > 90) {
        return MarettaStatus.unknown;
      } else if (diff.inMinutes > 60) {
        return MarettaStatus.alive;
      } else {
        return MarettaStatus.dead;
      }
    } else if (item.status == MarettaStatus.alive) {
      Duration diff = elapsed(context);
      if (diff.inMinutes < 30) {
        return MarettaStatus.alive;
      }
    }
    return MarettaStatus.unknown;
  }

  Color getColor(BuildContext context) {
    switch (getStatus(context)) {
      case (MarettaStatus.alive):
        return Colors.green;
      case (MarettaStatus.dead):
        return Colors.red;
      case (MarettaStatus.unknown):
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String statusToString(BuildContext context) {
    switch (getStatus(context)) {
      case (MarettaStatus.alive):
        return '생존';
      case (MarettaStatus.dead):
        return '사망️';
      case (MarettaStatus.unknown):
        return '확인 필요';
      default:
        return '확인 필요';
    }
  }

  Duration elapsed(BuildContext context) {
    if (item.statusAt == null) {
      return const Duration(days: 1);
    }
    return Provider.of<RealTimeNotifier>(context)
        .now
        .difference(item.statusAt!);
  }

  String elapsedToString(BuildContext context) {
    Duration diff = elapsed(context);
    if (diff.inMinutes > 60) {
      diff = diff - const Duration(hours: 1);
    }
    if (diff.inMinutes >= 0 && diff.inMinutes <= 1) {
      return '방금';
    } else if (diff.inMinutes > 1) {
      return '+${diff.inMinutes}분';
    } else {
      return '${diff.inMinutes}분';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: getStatus(context) == MarettaStatus.unknown
          ? null
          : () => showDetail(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.circle,
                    size: 10.0,
                    color: getColor(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    '${item.channelNumber}ch',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(statusToString(context)), // 생존 확인, 처치 확인, 확인 필요
                ),
              ],
            ),
            getStatus(context) == MarettaStatus.unknown
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(elapsedToString(context),
                        style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.6),
                            fontSize: 12.0)),
                  ),
          ],
        ),
      ),
    );
  }
}
