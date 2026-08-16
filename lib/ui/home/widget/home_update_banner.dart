import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/service/version_service.dart';
import 'package:karanda/ui/core/ui/dialog_kit.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';
import 'package:provider/provider.dart';

/// 새 버전이 감지되면 홈 상단에 뜨는 배너.
///
/// 사라지는 토스트 대신 배너를 쓰는 이유: 이 기능의 대상은 앱을 며칠씩 켜두는 사용자라,
/// 자리를 비운 사이 지나가버리는 알림은 의미가 없다.
class HomeUpdateBanner extends StatelessWidget {
  const HomeUpdateBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, VersionService service, child) {
        switch (service.state) {
          case UpdateState.idle:
            return const SizedBox.shrink();
          case UpdateState.available:
            return _AvailableCard(version: service.latestVersion?.text ?? "");
          case UpdateState.downloading:
            return _DownloadingCard(progress: service.progress);
          case UpdateState.failed:
            return const _FailedCard();
        }
      },
    );
  }
}

class _AvailableCard extends StatelessWidget {
  final String version;

  const _AvailableCard({required this.version});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.system_update_alt, color: Colors.blue),
        title: Text(context.tr("update.available", args: [version])),
        subtitle: InkWell(
          onTap: () => context.goWithGa("/settings/change-log"),
          child: Text(
            context.tr("update.change log"),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () => _confirm(context),
          child: Text(context.tr("update.update now")),
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final service = context.read<VersionService>();
    // 앱이 종료된다는 사실을 알리는 것이 이 다이얼로그의 존재 이유다.
    final confirmed = await DialogKit.of(context).doubleCheck(
      icon: const Icon(Icons.system_update_alt),
      title: Text(context.tr("update.update now")),
      content: Text(context.tr("update.restart warning")),
    );
    if (confirmed != true) return;
    await service.startUpdate();
  }
}

class _DownloadingCard extends StatelessWidget {
  final double progress;

  const _DownloadingCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.downloading),
        title: Text(context.tr("update.downloading")),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: LinearProgressIndicator(value: progress),
        ),
        trailing: Text("${(progress * 100).toStringAsFixed(0)}%"),
      ),
    );
  }
}

class _FailedCard extends StatelessWidget {
  const _FailedCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.error_outline, color: Colors.red),
        title: Text(context.tr("update.failed")),
        trailing: TextButton(
          onPressed: () => context.read<VersionService>().startUpdate(),
          child: Text(context.tr("update.retry")),
        ),
      ),
    );
  }
}
