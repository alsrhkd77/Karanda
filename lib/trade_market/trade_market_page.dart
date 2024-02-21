import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/trade_market/trade_market_notifier.dart';
import 'package:karanda/trade_market/trade_market_search_bar_widget.dart';
import 'package:karanda/trade_market/trade_market_wait_list_widget.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/loading_page.dart';
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
    if(context.watch<AuthNotifier>().waitResponse){
      return const LoadingPage();
    } else if(!context.watch<AuthNotifier>().authenticated) {
      return const LoadingPage();
    }

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
                            '통합 거래소 뷰어 (Beta)',
                            bold: true,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding, vertical: 12.0
                        ),
                        sliver: const SliverToBoxAdapter(
                          child: TradeMarketSearchBarWidget(),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
