import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/core/ui/section.dart';
import 'package:karanda/ui/desktop_download/controller/desktop_download_controller.dart';
import 'package:provider/provider.dart';

/// 웹 전용 Karanda Desktop 설치 파일 다운로드 페이지.
///
/// 최신 버전 정보를 표시하고 최신 `SetupKaranda.exe`를 내려받는 버튼을 제공한다.
/// 외부 사이트에서 `/desktop-download` 링크로 직접 진입할 수 있다.
class DesktopDownloadPage extends StatelessWidget {
  const DesktopDownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          DesktopDownloadController(versionRepository: context.read()),
      child: Scaffold(
        appBar: KarandaAppBar(
          icon: Icons.install_desktop,
          title: context.tr("desktopDownload.title"),
        ),
        body: PageBase(
          children: [
            Section(
              icon: Icons.install_desktop,
              title: context.tr("desktopDownload.title"),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: _DownloadContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadContent extends StatelessWidget {
  const _DownloadContent();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, DesktopDownloadController controller, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr("desktopDownload.description"),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),
            _LatestVersion(
              isLoading: controller.isLoading,
              version: controller.latestVersion?.text,
            ),
            const SizedBox(height: 16.0),
            FilledButton.icon(
              onPressed: controller.download,
              icon: const Icon(Icons.download),
              label: Text(context.tr("desktopDownload.download")),
            ),
          ],
        );
      },
    );
  }
}

class _LatestVersion extends StatelessWidget {
  final bool isLoading;
  final String? version;

  const _LatestVersion({required this.isLoading, required this.version});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 20.0,
          height: 20.0,
          child: CircularProgressIndicator(strokeWidth: 2.0),
        ),
      );
    }
    // 버전 조회 실패 시 버전 줄을 표시하지 않는다.
    if (version == null) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        Text(
          context.tr("desktopDownload.latestVersion"),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 8.0),
        Text(
          version!,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
