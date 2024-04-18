import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/common/custom_scroll_behavior.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/common/go_router_extension.dart';
import 'package:karanda/trade_market/trade_market_notifier.dart';
import 'package:karanda/trade_market/trade_market_search_bar_widget.dart';
import 'package:karanda/trade_market/trade_market_wait_list_widget.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:provider/provider.dart';

class TradeMarketPage extends StatefulWidget {
  const TradeMarketPage({super.key});

  @override
  State<TradeMarketPage> createState() => _TradeMarketPageState();
}

class _TradeMarketPageState extends State<TradeMarketPage> {
  @override
  Widget build(BuildContext context) {
    double horizontalPadding = GlobalProperties.scrollViewHorizontalPadding(
        MediaQuery.of(context).size.width);
    return Consumer<TradeMarketNotifier>(
      builder: (_, notifier, __) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            appBar: const DefaultAppBar(),
            body: notifier.itemInfo.isEmpty
                ? const Center(
                    child: LoadingIndicator(),
                  )
                : CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(
                        child: ListTile(
                          leading: Icon(FontAwesomeIcons.scaleUnbalanced),
                          title: TitleText(
                            '통합 거래소',
                            bold: true,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding, vertical: 12.0),
                        sliver: const SliverToBoxAdapter(
                          child: TradeMarketSearchBarWidget(),
                        ),
                      ),
                      SliverPadding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        sliver: const SliverToBoxAdapter(
                          child: ListTile(
                            title: TitleText(
                              '프리셋',
                              bold: true,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        sliver: SliverToBoxAdapter(
                          child: _Presets(
                            horizontalPadding: horizontalPadding,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        sliver: const SliverToBoxAdapter(
                          child: ListTile(
                            title: TitleText(
                              '등록 대기',
                              bold: true,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        sliver: const TradeMarketWaitListWidget(),
                      ),
                      SliverPadding(
                        padding: GlobalProperties.scrollViewPadding,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _PresetCard extends StatelessWidget {
  final String route;
  final String imagePath;
  final String title;
  final String description;

  const _PresetCard(
      {super.key,
      required this.route,
      required this.imagePath,
      required this.title,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: 280,
        height: 98,
        child: InkWell(
          onTap: () {
            context.goWithGa(route);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 4.0),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      Text(
                        description,
                        style: const TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Presets extends StatefulWidget {
  final double horizontalPadding;

  const _Presets({super.key, required this.horizontalPadding});

  @override
  State<_Presets> createState() => _PresetsState();
}

class _PresetsState extends State<_Presets> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: GlobalProperties.scrollViewVerticalPadding / 2),
      child: ScrollConfiguration(
        behavior: CustomScrollBehavior(),
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(
                bottom: GlobalProperties.scrollViewVerticalPadding / 2),
            controller: _scrollController,
            child: const Row(
              children: [
                _PresetCard(
                  route: '/trade-market/cooking-box',
                  imagePath: 'assets/image/cooking_box.png',
                  title: '황실 납품용 요리',
                  description: '황납 상자별 재료 요리',
                ),
                _PresetCard(
                  route: '/trade-market/melody-of-stars',
                  imagePath: 'assets/image/melody_of_stars.png',
                  title: '별들의 선율',
                  description: '선율 제작용 재료 악세',
                ),
                _PresetCard(
                  route: '/trade-market/dehkias-light',
                  imagePath: 'assets/image/dehkias_light.png',
                  title: '데키아의 불빛',
                  description: '불빛 제작용 재료 악세',
                ),
                _PresetCard(
                  route: '/trade-market/magical-lightstone-crystal',
                  imagePath: 'assets/image/magical_lightstone_crystal.png',
                  title: '마력의 광명석 결정',
                  description: '광명석 결정 제작 재료',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
