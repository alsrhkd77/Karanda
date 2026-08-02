import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/service/version_service.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';
import 'package:provider/provider.dart';

/// 앱바에 나타나는 업데이트 버튼과 팝오버.
///
/// 새 버전이 없을 때는 렌더되지 않는다. **없던 버튼이 생긴 것 자체가 알림**이라 배지를 따로 달지 않는다.
///
/// 배너 대신 앱바에 두는 이유: 홈은 스크롤되는 `ListView`라 배너는 위로 밀려 사라지는데,
/// 이 기능의 대상은 앱을 며칠씩 켜두는 사용자다. 앱바는 고정이고 홈 레이아웃도 밀어내지 않는다.
class UpdateMenuButton extends StatefulWidget {
  const UpdateMenuButton({super.key});

  @override
  State<UpdateMenuButton> createState() => _UpdateMenuButtonState();
}

class _UpdateMenuButtonState extends State<UpdateMenuButton> {
  /// 팝오버 폭. 최소 창 폭(600)의 절반이라 좁은 창에서도 넘치지 않는다.
  static const double _menuWidth = 300;

  /// 팝오버 내용에서도 닫을 수 있어야 해서 직접 보유한다.
  /// (`MenuController.maybeOf` 같은 조회 API는 없고, 매 빌드마다 새로 만들면 앵커와의 연결이 끊긴다.)
  final MenuController _controller = MenuController();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, VersionService service, child) {
        if (service.state == UpdateState.idle) {
          // 홈에서 조건부로 actions에 넣지 않는 방법도 있지만, 그러면 HomePage가 이 서비스를
          // 구독해야 해서 홈 전체가 리빌드된다. 여기서 처리하면 리빌드가 이 버튼에 갇힌다.
          return const SizedBox.shrink();
        }
        return MenuAnchor(
          controller: _controller,
          // 기본값(false)이면 바깥 탭이 아래로 통과해, 열린 상태에서 앵커를 누를 때
          // '메뉴 닫힘 → 같은 탭이 버튼에 전달 → 다시 열림'이 되어 반응 없는 버튼처럼 보인다.
          consumeOutsideTap: true,
          // LTR에서 메뉴는 '왼쪽 모서리'가 기준점에 놓인다(childSize.width를 빼지 않는다).
          // bottomEnd는 앵커의 오른쪽 모서리를 가리키므로, 거기서 메뉴 폭만큼 당겨야
          // 메뉴 오른쪽 끝이 버튼 오른쪽 끝에 맞는다.
          // 이렇게 하지 않으면 메뉴가 창 밖으로 넘쳐 강제로 안쪽에 밀어붙여지고,
          // 그 상태에서는 dx를 줘도 클램핑에 먹혀 아무 변화가 없다.
          alignmentOffset: const Offset(14-_menuWidth, 8),
          style: const MenuStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
            alignment: AlignmentDirectional.bottomEnd,
          ),
          menuChildren: [
            SizedBox(
              width: _menuWidth,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _MenuContents(
                  service: service,
                  controller: _controller,
                ),
              ),
            ),
          ],
          builder: (context, controller, child) {
            return IconButton(
              onPressed: () =>
                  controller.isOpen ? controller.close() : controller.open(),
              tooltip: _tooltip(context, service),
              icon: _anchorIcon(context, service),
            );
          },
        );
      },
    );
  }

  String _tooltip(BuildContext context, VersionService service) {
    switch (service.state) {
      case UpdateState.downloading:
        return context.tr(
          "update.downloading tooltip",
          args: ["${(service.progress * 100).floor()}"],
        );
      case UpdateState.failed:
        return context.tr("update.failed");
      default:
        // 아이콘만으로는 무엇이 새로운지 알 수 없어 툴팁이 정보 전달을 맡는다.
        return context.tr(
          "update.new version",
          args: [service.latestVersion?.text ?? ""],
        );
    }
  }

  Widget _anchorIcon(BuildContext context, VersionService service) {
    switch (service.state) {
      case UpdateState.downloading:
        // 진행률로 버튼을 통째로 바꾸면 다운로드 중 팝오버를 다시 열 수 없다.
        // IconButton의 icon 자리에 넣어 클릭을 살려둔다.
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            value: service.progress,
          ),
        );
      case UpdateState.failed:
        return Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
        );
      default:
        return const Icon(Icons.system_update_alt);
    }
  }
}

class _MenuContents extends StatelessWidget {
  final VersionService service;
  final MenuController controller;

  const _MenuContents({required this.service, required this.controller});

  @override
  Widget build(BuildContext context) {
    switch (service.state) {
      case UpdateState.downloading:
        return _Downloading(progress: service.progress);
      case UpdateState.failed:
        return const _Failed();
      default:
        return _Available(
          version: service.latestVersion?.text ?? "",
          controller: controller,
        );
    }
  }
}

class _Available extends StatelessWidget {
  final String version;
  final MenuController controller;

  const _Available({required this.version, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.tr("update.new version", args: [version]),
          style: TextTheme.of(context).titleSmall,
        ),
        const SizedBox(height: 8),
        // 종료된다는 사실을 여기서 알리므로 별도 확인 다이얼로그를 두지 않는다.
        // 팝오버를 여는 행위 자체가 이미 한 단계의 확인이다.
        Text(
          context.tr("update.restart warning"),
          style: TextTheme.of(context)
              .bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.outline),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                // 홈을 떠나면 MenuAnchor가 통째로 사라지므로 먼저 닫는다.
                controller.close();
                context.goWithGa("/settings/change-log");
              },
              child: Text(context.tr("update.change log")),
            ),
            const SizedBox(width: 8),
            FilledButton(
              // 팝오버를 닫지 않는다. 상태가 downloading으로 바뀌면 이 자리가 진행률로 전환된다.
              onPressed: () => context.read<VersionService>().startUpdate(),
              child: Text(context.tr("update.update now")),
            ),
          ],
        ),
      ],
    );
  }
}

class _Downloading extends StatelessWidget {
  final double progress;

  const _Downloading({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.tr("update.downloading"),
          style: TextTheme.of(context).titleSmall,
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "${(progress * 100).floor()}%",
            style: TextTheme.of(context).bodySmall,
          ),
        ),
      ],
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.tr("update.failed"),
          style: TextTheme.of(context).titleSmall,
        ),
        const SizedBox(height: 8),
        Text(
          context.tr("update.failed hint"),
          style: TextTheme.of(context)
              .bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.outline),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: () => context.read<VersionService>().startUpdate(),
            child: Text(context.tr("update.retry")),
          ),
        ),
      ],
    );
  }
}
