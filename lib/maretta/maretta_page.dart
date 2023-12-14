import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:karanda/common/channel.dart';
import 'package:karanda/common/real_time_notifier.dart';
import 'package:karanda/maretta/maretta_blacklist_dialog.dart';
import 'package:karanda/maretta/maretta_channel_model.dart';
import 'package:karanda/maretta/maretta_detail_dialog.dart';
import 'package:karanda/maretta/maretta_model.dart';
import 'package:karanda/maretta/maretta_notifier.dart';
import 'package:karanda/maretta/maretta_report_dialog.dart';
import 'package:karanda/maretta/maretta_report_model.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:provider/provider.dart';

class MarettaPage extends StatefulWidget {
  const MarettaPage({super.key});

  @override
  State<MarettaPage> createState() => _MarettaPageState();
}

class _MarettaPageState extends State<MarettaPage> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _timer = Timer.periodic(const Duration(minutes: 3),
          (timer) => context.read<MarettaNotifier>().getReports());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> report() async {
    MarettaReportModel? item = await showDialog(
        context: context, builder: (_) => const MarettaReportDialog());
    if (item != null) {
      await context.read<MarettaNotifier>().createReport(item);
    }
  }

  Future<void> showBlacklist() async {
    await showDialog(
        context: context, builder: (_) => const MarettaBlacklistDialog());
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
              trailing: ElevatedButton(
                onPressed: showBlacklist,
                child: const Text('제외한 제보자'),
              ),
            ),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: Provider.of<MarettaNotifier>(context)
                  .list
                  .map((e) => _ChannelCard(
                        item: e,
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
  final MarettaChannelModel item;

  const _ChannelCard({super.key, required this.item});

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
                Channel.toKrServerName(item.channel),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ...item.details.map((e) => _ChannelLine(item: e)).toList(),
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
      print(dialog);
    }
  }

  MarettaStatus getStatus(BuildContext context) {
    if (item.status == MarettaStatus.dead) {
      Duration diff = elapsed(context);
      if (diff.inMinutes > 60) {
        return MarettaStatus.unknown;
      }
    }
    return item.status;
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
        return '생존 확인';
      case (MarettaStatus.dead):
        return '처치 확인';
      case (MarettaStatus.unknown):
        return '확인 필요';
      default:
        return '확인 필요';
    }
  }

  Duration elapsed(BuildContext context) {
    return Provider.of<RealTimeNotifier>(context)
        .now
        .difference(item.report.first.reportAt);
  }

  String elapsedToString(BuildContext context) {
    Duration diff = elapsed(context);
    if (diff.inMinutes < 1) {
      return '방금';
    } else {
      return '${diff.inMinutes}분 전';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.status == MarettaStatus.unknown
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
            item.status == MarettaStatus.unknown
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
