import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/trade_market/templates/controllers/trade_market_template_list_controller.dart';
import 'package:karanda/ui/trade_market/templates/widgets/trade_market_template_view_page.dart';
import 'package:karanda/ui/trade_market/widgets/trade_market_search_bar_widget.dart';
import 'package:karanda/utils/extension/build_context_extension.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';
import 'package:provider/provider.dart';

class TradeMarketPage extends StatelessWidget {
  const TradeMarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: KarandaAppBar(
          title: context.tr("trade market.trade market"),
          icon: FontAwesomeIcons.scaleUnbalanced,
        ),
        body: PageBase(
          children: [
            const TradeMarketSearchBarWidget(),
            const SizedBox(height: 8),
            const _QueuedListButtonTile(),
            const SizedBox(height: 8),
            ListTile(
              title: Text(context.tr("trade market.presets")),
            ),
            const _TemplateGrid(),
          ],
        ),
      ),
    );
  }
}

class _QueuedListButtonTile extends StatelessWidget {
  const _QueuedListButtonTile();

  @override
  Widget build(BuildContext context) {
    final region = context.region;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: const Icon(FontAwesomeIcons.clock),
        title: Text(context.tr("trade market.wait list")),
        trailing: const Icon(Icons.chevron_right),
        onTap: region == null
            ? null
            : () {
                context.goWithGa("/trade-market/${region.name}/queued");
              },
      ),
    );
  }
}

/// 빌트인과 사용자 템플릿을 한 종류의 카드로 보여준다.
/// 고정 프리셋과 사용자 템플릿의 구분은 리뉴얼로 사라졌다.
class _TemplateGrid extends StatelessWidget {
  const _TemplateGrid();

  @override
  Widget build(BuildContext context) {
    final region = context.region;
    if (region == null) {
      return const LoadingIndicator();
    }
    return ChangeNotifierProvider(
      create: (context) => TradeMarketTemplateListController(
        tradeMarketService: context.read(),
      ),
      child: Consumer(
        builder: (context, TradeMarketTemplateListController controller, child) {
          final templates = controller.templates;
          if (templates == null) {
            return const LoadingIndicator();
          }
          final width = MediaQuery.sizeOf(context).width;
          final crossAxisCount = width > 900 ? 3 : (width > 600 ? 2 : 1);

          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            childAspectRatio: 3.2,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: [
              _CookingBoxCard(region: region),
              ...templates.map((template) => _TemplateCard(
                    region: region,
                    template: template,
                  )),
              _AddTemplateCard(region: region),
            ],
          );
        },
      ),
    );
  }
}

/// 요리상자는 공헌도·숙련도 입력이 게임 사양이라 템플릿으로 표현할 수 없어 전용 화면을 쓴다.
class _CookingBoxCard extends StatelessWidget {
  final BDORegion region;

  const _CookingBoxCard({required this.region});

  @override
  Widget build(BuildContext context) {
    return _GridCard(
      onTap: () => context.goWithGa("/trade-market/${region.name}/cooking-box"),
      leading: Padding(
        padding: const EdgeInsets.all(4),
        child:
            Image.asset('assets/image/cooking_box.png', fit: BoxFit.fitHeight),
      ),
      title: context.tr("trade market.cooking_box"),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final BDORegion region;
  final TradeMarketTemplate template;

  const _TemplateCard({required this.region, required this.template});

  /// 이미지가 있는 빌트인만 그림을 쓴다. 나머지는 아이콘으로 대체한다.
  static const Set<String> _imageKeys = {
    'melody_of_stars',
    'dehkias_light',
    'magical_lightstone_crystal',
    'essence_of_dawn',
  };

  @override
  Widget build(BuildContext context) {
    return _GridCard(
      onTap: () => context.goWithGa(
          "/trade-market/${region.name}/templates/${template.id}"),
      leading: _leading(),
      title: TradeMarketTemplateViewPage.templateName(context, template),
      subtitle: context.tr(
        "trade market.templates.item count",
        args: [_itemCount().toString()],
      ),
    );
  }

  Widget _leading() {
    if (template.isBuiltIn && _imageKeys.contains(template.id)) {
      return Padding(
        padding: const EdgeInsets.all(4),
        child: Image.asset(
          'assets/image/${template.id}.png',
          fit: BoxFit.fitHeight,
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Icon(FontAwesomeIcons.listUl),
    );
  }

  /// 제작법 비교형은 본문 대신 제작법에 아이템이 들어 있다.
  int _itemCount() {
    if (template.variants.isEmpty) {
      return template.items.length;
    }
    return template.variants.fold<int>(
      0,
      (sum, variant) => sum + variant.items.length,
    );
  }
}

class _AddTemplateCard extends StatelessWidget {
  final BDORegion region;

  const _AddTemplateCard({required this.region});

  @override
  Widget build(BuildContext context) {
    return _GridCard(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      onTap: () =>
          context.goWithGa("/trade-market/${region.name}/templates/new"),
      leading: const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Icons.add),
      ),
      title: context.tr("trade market.templates.add template"),
    );
  }
}

class _GridCard extends StatelessWidget {
  final VoidCallback onTap;
  final Widget leading;
  final String title;
  final String? subtitle;
  final Color? color;

  const _GridCard({
    required this.onTap,
    required this.leading,
    required this.title,
    this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
          child: Row(
            children: [
              leading,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextTheme.of(context).bodyLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextTheme.of(context).bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
