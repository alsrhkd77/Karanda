import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/ui/core/theme/dimes.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/trade_market/widgets/trade_market_search_bar_widget.dart';
import 'package:karanda/ui/trade_market/widgets/trade_market_wait_list_widget.dart';
import 'package:karanda/utils/custom_scroll_behavior.dart';
import 'package:karanda/utils/extension/build_context_extension.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';

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
            ListTile(
              title: Text(context.tr("trade market.presets")),
            ),
            const _Presets(),
            ListTile(
              title: Text(context.tr("trade market.wait list")),
            ),
            const TradeMarketWaitListWidget(),
          ],
        ),
      ),
    );
  }
}

class _Presets extends StatefulWidget {
  const _Presets({super.key});

  @override
  State<_Presets> createState() => _PresetsState();
}

class _PresetsState extends State<_Presets> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final region = context.region;
    if (region == null) {
      return const LoadingIndicator();
    }
    return SizedBox(
      height: 120,
      child: Scrollbar(
        controller: scrollController,
        child: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: ListView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: Dimens.pagePaddingValue),
            itemExtent: 300,
            children: [
              _PresetCard(
                route: '/trade-market/${region.name}/cooking-box',
                imagePath: 'assets/image/cooking_box.png',
                title: context.tr("trade market.cooking_box"),
                description: '황납 상자별 재료 요리',
              ),
              _PresetCard(
                route: '/trade-market/${region.name}/melody-of-stars',
                imagePath: 'assets/image/melody_of_stars.png',
                title: context.tr("trade market.melody_of_stars"),
                description: '선율 제작용 재료 악세',
              ),
              _PresetCard(
                route: '/trade-market/${region.name}/dehkias-light',
                imagePath: 'assets/image/dehkias_light.png',
                title: context.tr("trade market.dehkias_light"),
                description: '불빛 제작용 재료 악세',
              ),
              _PresetCard(
                route:
                    '/trade-market/${region.name}/magical-lightstone-crystal',
                imagePath: 'assets/image/magical_lightstone_crystal.png',
                title: context.tr("trade market.magical_lightstone_crystal"),
                description: '광명석 결정 제작 재료',
              ),
              _PresetCard(
                route:
                '/trade-market/${region.name}/essence-of-dawn',
                imagePath: 'assets/image/essence_of_dawn.png',
                title: context.tr("trade market.essence_of_dawn"),
                description: '새벽의 정수 제작용 재료 악세',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  final String route;
  final String imagePath;
  final String title;
  final String description;

  const _PresetCard({
    super.key,
    required this.route,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.goWithGa(route);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(imagePath, fit: BoxFit.fitHeight),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2.0,
                    vertical: 12.0,
                  ),
                  child: Text(
                    title,
                    style: TextTheme.of(context).bodyLarge,
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
