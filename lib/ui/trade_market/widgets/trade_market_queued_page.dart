import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/trade_market/widgets/trade_market_wait_list_widget.dart';

class TradeMarketQueuedPage extends StatelessWidget {
  final BDORegion region;

  const TradeMarketQueuedPage({super.key, required this.region});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KarandaAppBar(
        title: context.tr("trade market.wait list"),
        icon: FontAwesomeIcons.clock,
      ),
      body: PageBase(
        children: const [
          TradeMarketWaitListWidget(),
        ],
      ),
    );
  }
}
