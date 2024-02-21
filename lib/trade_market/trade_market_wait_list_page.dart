import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/trade_market/trade_market_wait_list_widget.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_page.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:provider/provider.dart';

/*
* Unused
 */

class TradeMarketWaitListPage extends StatefulWidget {
  const TradeMarketWaitListPage({super.key});

  @override
  State<TradeMarketWaitListPage> createState() => _TradeMarketWaitListPageState();
}

class _TradeMarketWaitListPageState extends State<TradeMarketWaitListPage> {
  @override
  Widget build(BuildContext context) {
    if(context.watch<AuthNotifier>().waitResponse){
      return const LoadingPage();
    } else if(!context.watch<AuthNotifier>().authenticated) {
      return const LoadingPage();
    }
    double horizontalPadding = GlobalProperties.scrollViewHorizontalPadding(
        MediaQuery.of(context).size.width);
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: ListTile(
              leading: Icon(FontAwesomeIcons.scaleUnbalanced),
              title: TitleText(
                '거래소 등록 대기',
                bold: true,
              ),
            ),
          ),
          SliverPadding(
            padding: GlobalProperties.scrollViewPadding,
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
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
