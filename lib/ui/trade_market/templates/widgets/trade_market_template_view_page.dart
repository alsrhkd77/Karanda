import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:karanda/ui/core/theme/dimens.dart';
import 'package:karanda/ui/core/ui/bdo_item_image.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/trade_market/templates/controllers/trade_market_template_view_controller.dart';
import 'package:karanda/utils/extension/build_context_extension.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';
import 'package:karanda/utils/extension/int_extension.dart';
import 'package:provider/provider.dart';

class TradeMarketTemplateViewPage extends StatelessWidget {
  final String templateId;
  final BDORegion region;

  const TradeMarketTemplateViewPage({
    super.key,
    required this.templateId,
    required this.region,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TradeMarketTemplateViewController(
        tradeMarketService: context.read(),
        templateId: templateId,
        region: region,
      ),
      child: Consumer(
        builder: (context, TradeMarketTemplateViewController controller, child) {
          return Scaffold(
            appBar: KarandaAppBar(
              title: controller.template?.name ??
                  context.tr("trade market.templates.template"),
              icon: FontAwesomeIcons.scaleUnbalanced,
              actions: [
                if (controller.template != null)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: context.tr("trade market.templates.edit template"),
                    onPressed: () {
                      context.goWithGa(
                          "/trade-market/${region.name}/templates/$templateId/edit");
                    },
                  ),
              ],
            ),
            body: _buildBody(context, controller),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TradeMarketTemplateViewController controller,
  ) {
    if (controller.notFound) {
      return Center(
        child: Text(context.tr("trade market.templates.not found")),
      );
    }
    if (controller.template == null) {
      return const LoadingIndicator();
    }
    if (controller.template!.items.isEmpty) {
      return Center(
        child: Text(context.tr("trade market.templates.empty items")),
      );
    }
    if (controller.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(context.tr("trade market.failed to get data")),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.refresh),
              label: Text(context.tr("trade market.templates.retry")),
              onPressed: controller.retry,
            ),
          ],
        ),
      );
    }
    if (!controller.isLoaded) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingIndicator(),
          Text(context.tr(
            "trade market.preset waiting",
            args: [controller.template!.items.length.toString()],
          )),
        ],
      );
    }

    final materials = controller.materials ?? [];
    final results = controller.results ?? [];
    return PageBase(
      children: [
        _Summary(
          materialsTotal: controller.materialsTotal,
          resultsTotal: controller.resultsTotal,
          difference: controller.difference,
        ),
        if (materials.isNotEmpty) ...[
          ListTile(
            title: Text(
              context.tr("trade market.templates.material"),
              style: TextTheme.of(context).titleMedium,
            ),
          ),
          ...materials.map((item) => _ItemTile(region: region, item: item)),
        ],
        if (results.isNotEmpty) ...[
          ListTile(
            title: Text(
              context.tr("trade market.templates.result"),
              style: TextTheme.of(context).titleMedium,
            ),
          ),
          ...results.map((item) => _ItemTile(region: region, item: item)),
        ],
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  final int materialsTotal;
  final int resultsTotal;
  final int difference;

  const _Summary({
    super.key,
    required this.materialsTotal,
    required this.resultsTotal,
    required this.difference,
  });

  @override
  Widget build(BuildContext context) {
    final Color differenceColor = difference > 0
        ? Colors.green.shade400
        : (difference < 0 ? Colors.red : Colors.orange);
    return Card(
      margin: const EdgeInsets.all(4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _SummaryRow(
              label: context.tr("trade market.templates.materials total"),
              value: materialsTotal.format(),
            ),
            _SummaryRow(
              label: context.tr("trade market.templates.results total"),
              value: resultsTotal.format(),
            ),
            const Divider(),
            _SummaryRow(
              label: context.tr("trade market.templates.difference"),
              value: difference.format(),
              valueColor: differenceColor,
              emphasize: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;

  const _SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        emphasize ? TextTheme.of(context).titleMedium : TextTheme.of(context).bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: baseStyle),
          Text(value, style: baseStyle?.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final BDORegion region;
  final TradeMarketTemplateItem item;

  const _ItemTile({
    super.key,
    required this.region,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final itemInfo = context.itemInfo(item.code.toString());
    final price = item.price;
    final bool inStock = (price?.currentStock ?? 0) > 0;
    return Card(
      margin: const EdgeInsets.all(4.0),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: Dimens.listTileContentsPadding(),
        leading: BdoItemImage(
          code: itemInfo.code,
          enhancementLevel: item.enhancementLevel,
        ),
        title: Text(
          "${context.itemName(itemInfo.code, item.enhancementLevel)} × ${item.value}",
        ),
        subtitle: price == null
            ? null
            : Text(context.tr(
                "trade market.templates.item subtotal",
                namedArgs: {
                  "total": (price.price * item.value).format(),
                  "single": price.price.format(),
                },
              )),
        trailing: price == null
            ? null
            : (inStock
                ? Text(price.price.format())
                : Text(
                    "${price.price.format()} (${context.tr("trade market.preset item out of stock")})",
                    style: const TextStyle(color: Colors.red),
                  )),
        onTap: () {
          context.goWithGa("/trade-market/${region.name}/detail/${itemInfo.code}");
        },
      ),
    );
  }
}
