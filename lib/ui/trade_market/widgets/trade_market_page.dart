import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/trade_market/templates/controllers/trade_market_template_list_controller.dart';
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
            const _PresetGrid(),
          ],
        ),
      ),
    );
  }
}

class _QueuedListButtonTile extends StatelessWidget {
  const _QueuedListButtonTile({super.key});

  @override
  Widget build(BuildContext context) {
    final region = context.region;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(FontAwesomeIcons.clock),
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

class _PresetGrid extends StatelessWidget {
  const _PresetGrid({super.key});

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
          final width = MediaQuery.sizeOf(context).width;
          final crossAxisCount = width > 900 ? 3 : (width > 600 ? 2 : 1);

          final List<Widget> cards = [
            _PresetCard(
              route: '/trade-market/${region.name}/cooking-box',
              imagePath: 'assets/image/cooking_box.png',
              title: context.tr("trade market.cooking_box"),
            ),
            _PresetCard(
              route: '/trade-market/${region.name}/essence-of-dawn',
              imagePath: 'assets/image/essence_of_dawn.png',
              title: context.tr("trade market.essence_of_dawn"),
            ),
            _PresetCard(
              route: '/trade-market/${region.name}/dehkias-light',
              imagePath: 'assets/image/dehkias_light.png',
              title: context.tr("trade market.dehkias_light"),
            ),
            _PresetCard(
              route: '/trade-market/${region.name}/melody-of-stars',
              imagePath: 'assets/image/melody_of_stars.png',
              title: context.tr("trade market.melody_of_stars"),
            ),
            _PresetCard(
              route: '/trade-market/${region.name}/magical-lightstone-crystal',
              imagePath: 'assets/image/magical_lightstone_crystal.png',
              title: context.tr("trade market.magical_lightstone_crystal"),
            ),
            if (templates != null)
              ...templates.map((template) => _TemplateCard(
                    region: region,
                    template: template,
                  )),
            _AddTemplateCard(region: region),
          ];

          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            childAspectRatio: 3.2,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: cards,
          );
        },
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  final String route;
  final String imagePath;
  final String title;

  const _PresetCard({
    super.key,
    required this.route,
    required this.imagePath,
    required this.title,
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

class _TemplateCard extends StatelessWidget {
  final BDORegion region;
  final TradeMarketTemplate template;

  const _TemplateCard({
    super.key,
    required this.region,
    required this.template,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.goWithGa(
              "/trade-market/${region.name}/templates/${template.id}");
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(FontAwesomeIcons.listUl),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      template.name,
                      style: TextTheme.of(context).bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      context.tr(
                        "trade market.templates.item count",
                        args: [template.items.length.toString()],
                      ),
                      style: TextTheme.of(context).bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddTemplateCard extends StatelessWidget {
  final BDORegion region;

  const _AddTemplateCard({super.key, required this.region});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () {
          context.goWithGa("/trade-market/${region.name}/templates/new");
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add),
              const SizedBox(width: 8),
              Text(
                context.tr("trade market.templates.add template"),
                style: TextTheme.of(context).bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
