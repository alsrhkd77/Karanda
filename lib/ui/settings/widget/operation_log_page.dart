import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/utils/file_saver/file_saver.dart';
import 'package:karanda/model/operation_log_record.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/core/ui/snack_bar_kit.dart';
import 'package:karanda/ui/operation_log/controller/operation_log_controller.dart';
import 'package:provider/provider.dart';

class OperationLogPage extends StatelessWidget {
  const OperationLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 내보내기 버튼이 AppBar에 있으므로 Provider가 Scaffold 바깥을 감싸야 한다.
    return ChangeNotifierProvider(
      create: (context) => OperationLogController()..load(),
      child: Consumer(
        builder: (context, OperationLogController controller, child) {
          return Scaffold(
            appBar: KarandaAppBar(
              icon: Icons.receipt_long_outlined,
              title: context.tr("settings.operation log"),
              actions: controller.isEmpty
                  ? null
                  : [
                      IconButton(
                        icon: const Icon(Icons.ios_share_outlined),
                        tooltip: context.tr("settings.operation log export"),
                        onPressed: () => _export(context, controller),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_outlined),
                        tooltip: context.tr("settings.operation log copy"),
                        onPressed: () => _copy(context, controller),
                      ),
                    ],
            ),
            body: _Body(controller: controller),
          );
        },
      ),
    );
  }

  Future<void> _export(
    BuildContext context,
    OperationLogController controller,
  ) async {
    final locale = context.locale.toString();
    try {
      final result = await controller.exportToFile(locale: locale);
      if (!context.mounted) return;
      switch (result) {
        case FileSaveResult.saved:
          SnackBarKit.of(context)
              .success(context.tr("settings.operation log exported"));
        case FileSaveResult.shared:
          // 공유 시트가 결과를 직접 보여주므로 별도 안내를 띄우지 않는다.
          break;
        case FileSaveResult.unsupported:
          SnackBarKit.of(context)
              .failed(context.tr("settings.operation log export unsupported"));
      }
    } catch (e) {
      if (!context.mounted) return;
      SnackBarKit.of(context)
          .failed(context.tr("settings.operation log export failed"));
    }
  }

  Future<void> _copy(
    BuildContext context,
    OperationLogController controller,
  ) async {
    final locale = context.locale.toString();
    await controller.copyToClipboard(locale: locale);
    if (!context.mounted) return;
    SnackBarKit.of(context)
        .success(context.tr("settings.operation log copied"));
  }
}

class _Body extends StatelessWidget {
  final OperationLogController controller;

  const _Body({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const LoadingIndicator();
    }
    final records = controller.records;
    if (records.isEmpty) {
      return Center(
        child: Text(context.tr("settings.operation log empty")),
      );
    }
    return PageBase(
      children: records.map((record) => _LogTile(record: record)).toList(),
    );
  }
}

class _LogTile extends StatelessWidget {
  final OperationLogRecord record;

  const _LogTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final leading = Icon(_levelIcon, color: _levelColor);
    final title = Text(record.message);
    final repeated = record.repeatCount > 1;
    final subtitle = Text(
      repeated
          ? "${DateFormat('MM-dd HH:mm:ss').format(record.time)}"
              " ~ ${DateFormat('HH:mm:ss').format(record.lastTime)}"
              " · ${record.loggerName} · x${record.repeatCount}"
          : "${DateFormat('MM-dd HH:mm:ss').format(record.time)} · ${record.loggerName}",
      style: TextTheme.of(context).bodySmall?.copyWith(color: Colors.grey),
    );

    final stackTrace = record.stackTrace;
    if (stackTrace == null) {
      return ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        isThreeLine: false,
      );
    }

    // 스택트레이스는 심각 오류에만 붙는다. 평소에는 접어두고 필요할 때만 펼쳐 본다.
    return ExpansionTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          stackTrace,
          style: TextTheme.of(context).bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: Colors.grey,
              ),
        ),
      ],
    );
  }

  IconData get _levelIcon {
    switch (record.level) {
      case 'SHOUT':
      case 'SEVERE':
        return Icons.error_outline;
      case 'WARNING':
        return Icons.warning_amber_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color? get _levelColor {
    switch (record.level) {
      case 'SHOUT':
      case 'SEVERE':
        return Colors.red;
      case 'WARNING':
        return Colors.orange;
      default:
        return null;
    }
  }
}
