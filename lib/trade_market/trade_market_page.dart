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
                        sliver: const SliverToBoxAdapter(
                          child: _Presets(),
                        ),
                      ),
                      SliverPadding(
                        padding: GlobalProperties.scrollViewPadding,
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

  const _PresetCard(
      {super.key,
      required this.route,
      required this.imagePath,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: 260,
        height: 56,
        child: Center(
          child: ListTile(
            onTap: () {
              context.goWithGa(route);
            },
            contentPadding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            leading: Image.asset(imagePath),
            title: Text(title),
          ),
        ),
      ),
    );
  }
}

class _Presets extends StatelessWidget {
  const _Presets({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: CustomScrollBehavior(),
      child: const SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _PresetCard(
              route: '/trade-market/cooking-box',
              imagePath: 'assets/image/cooking_box.png',
              title: '황납용 요리',
            ),
            _PresetCard(
              route: '/trade-market/melody-of-stars',
              imagePath: 'assets/image/melody_of_stars.png',
              title: '별들의 선율',
            ),
            _PresetCard(
              route: '/trade-market/magical-lightstone-crystal',
              imagePath: 'assets/image/magical_lightstone_crystal.png',
              title: '마력의 광명석 결정',
            ),
          ],
        ),
      ),
    );
  }
}
