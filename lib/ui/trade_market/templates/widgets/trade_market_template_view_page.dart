import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:karanda/ui/core/theme/dimens.dart';
import 'package:karanda/ui/core/ui/bdo_item_image.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/core/ui/snack_bar_kit.dart';
import 'package:karanda/ui/trade_market/templates/controllers/trade_market_template_view_controller.dart';
import 'package:karanda/utils/extension/build_context_extension.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';
import 'package:karanda/utils/extension/int_extension.dart';
import 'package:provider/provider.dart';

/// 템플릿 결과 화면.
///
/// 골격(헤더 → 조건 칩 → 요약 → 아이템 목록)은 타입 공통이고,
/// 요약 블록과 행 부가정보만 타입별로 갈린다.
class TradeMarketTemplateViewPage extends StatelessWidget {
  final String templateId;
  final BDORegion region;

  const TradeMarketTemplateViewPage({
    super.key,
    required this.templateId,
    required this.region,
  });

  /// 빌트인의 `name`은 i18n 키다. 사용자 템플릿은 사용자가 붙인 이름을 그대로 쓴다.
  static String templateName(
    BuildContext context,
    TradeMarketTemplate template,
  ) {
    return template.isBuiltIn
        ? context.tr("trade market.${template.id}")
        : template.name;
  }

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
          final template = controller.template;
          return Scaffold(
            appBar: KarandaAppBar(
              title: template == null
                  ? context.tr("trade market.templates.template")
                  : templateName(context, template),
              icon: FontAwesomeIcons.scaleUnbalanced,
              actions: [
                if (template != null && controller.isBuiltIn)
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: context
                        .tr("trade market.templates.copy to my templates"),
                    onPressed: () => _copy(context, controller, template),
                  ),
                if (template != null && !controller.isBuiltIn)
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

  Future<void> _copy(
    BuildContext context,
    TradeMarketTemplateViewController controller,
    TradeMarketTemplate template,
  ) async {
    final name = templateName(context, template);
    final id = await controller.copyToMyTemplates(name);
    if (id == null || !context.mounted) {
      return;
    }
    SnackBarKit.of(context)
        .success(context.tr("trade market.templates.copied", args: [name]));
    context.goWithGa("/trade-market/${region.name}/templates/$id");
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
    if (controller.template!.items.isEmpty && controller.variants.isEmpty) {
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

    switch (controller.type) {
      case TradeMarketTemplateType.unitPrice:
        return _UnitPriceBody(region: region, controller: controller);
      case TradeMarketTemplateType.shoppingList:
        return _ShoppingListBody(region: region, controller: controller);
      case TradeMarketTemplateType.recipeCompare:
        return _RecipeCompareBody(region: region, controller: controller);
      case TradeMarketTemplateType.profit:
        return _ProfitBody(region: region, controller: controller);
    }
  }
}

class _UnitPriceBody extends StatelessWidget {
  final BDORegion region;
  final TradeMarketTemplateViewController controller;

  const _UnitPriceBody({required this.region, required this.controller});

  @override
  Widget build(BuildContext context) {
    final items = controller.sortedByUnitPrice;
    return PageBase(
      children: [
        ListTile(
          leading: const Icon(Icons.arrow_downward, size: 20),
          title: Text(
            context.tr(
              "trade market.templates.sorted by unit price",
              args: [
                _unitPriceLabel(context),
                items.length.toString(),
              ],
            ),
            style: TextTheme.of(context).bodyMedium,
          ),
        ),
        ...items.map((item) => _ItemTile(
              region: region,
              item: item,
              inStock: controller.inStock(item),
              // 최저가는 정렬로 이미 맨 위에 오므로 배지 없이 색으로만 구분한다.
              highlight: identical(item, items.first) && controller.inStock(item),
              subtitle: _unitPriceText(context, item),
              trailingValue: item.unitCost,
            )),
      ],
    );
  }

  /// 빌트인은 "결정 1개당 {}"처럼 고유 문구를 갖는다.
  /// 사용자가 만든 단가 비교형 템플릿에는 그 문구가 없으므로 일반 문구로 대체한다.
  String _efficiencyKey() =>
      "trade market.${controller.template!.id}Efficiency";

  bool get _hasEfficiencyText {
    if (!controller.isBuiltIn) {
      return false;
    }
    final key = _efficiencyKey();
    return key.tr() != key;
  }

  String _unitPriceLabel(BuildContext context) {
    if (_hasEfficiencyText) {
      return _efficiencyKey().tr(args: const [""]).trim();
    }
    return context
        .tr("trade market.templates.unit price each", args: const [""])
        .trim();
  }

  String? _unitPriceText(BuildContext context, TradeMarketTemplateItem item) {
    final unit = controller.unitPriceOf(item);
    if (unit == null) {
      return null;
    }
    if (_hasEfficiencyText) {
      return _efficiencyKey().tr(args: [unit.format()]);
    }
    return context.tr(
      "trade market.templates.unit price each",
      args: [unit.format()],
    );
  }
}

class _ShoppingListBody extends StatelessWidget {
  final BDORegion region;
  final TradeMarketTemplateViewController controller;

  const _ShoppingListBody({required this.region, required this.controller});

  @override
  Widget build(BuildContext context) {
    final items = controller.items;
    return PageBase(
      children: [
        Card(
          margin: const EdgeInsets.all(4.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "${context.tr("trade market.templates.total cost")} · ${context.tr("trade market.templates.item count summary", args: [
                          items.length.toString()
                        ])}",
                    style: TextTheme.of(context).bodyMedium,
                  ),
                ),
                Text(
                  controller.total.format(),
                  style: TextTheme.of(context).headlineSmall,
                ),
              ],
            ),
          ),
        ),
        ...items.map((item) => _ItemTile(
              region: region,
              item: item,
              inStock: controller.inStock(item),
              subtitle: item.unitCost == null
                  ? null
                  : context.tr(
                      "trade market.templates.unit price each",
                      args: [item.unitCost!.format()],
                    ),
              trailingValue: item.totalCost,
            )),
      ],
    );
  }
}

class _ProfitBody extends StatelessWidget {
  final BDORegion region;
  final TradeMarketTemplateViewController controller;

  const _ProfitBody({required this.region, required this.controller});

  @override
  Widget build(BuildContext context) {
    final materials = controller.materials ?? [];
    final results = controller.results ?? [];
    return PageBase(
      children: [
        _ConditionChips(controller: controller),
        _Summary(controller: controller),
        if (materials.isNotEmpty) ...[
          ListTile(
            title: Text(
              context.tr("trade market.templates.material"),
              style: TextTheme.of(context).titleMedium,
            ),
          ),
          ...materials.map((item) => _ItemTile(
                region: region,
                item: item,
                inStock: controller.inStock(item),
                subtitle: _subtotalText(context, item),
                trailingValue: item.totalCost,
              )),
        ],
        if (results.isNotEmpty) ...[
          ListTile(
            title: Text(
              context.tr("trade market.templates.result"),
              style: TextTheme.of(context).titleMedium,
            ),
          ),
          ...results.map((item) => _ItemTile(
                region: region,
                item: item,
                inStock: controller.inStock(item),
                subtitle: _subtotalText(context, item),
                trailingValue: item.totalCost,
              )),
        ],
      ],
    );
  }

  String? _subtotalText(BuildContext context, TradeMarketTemplateItem item) {
    final unit = item.unitCost;
    if (unit == null) {
      return null;
    }
    return context.tr(
      "trade market.templates.item subtotal",
      namedArgs: {
        "total": (item.totalCost ?? 0).format(),
        "single": unit.format(),
      },
    );
  }
}

/// 제작법 비교형 본문. 제작법별 총 원가를 나란히 놓고 최저가를 강조한다.
class _RecipeCompareBody extends StatelessWidget {
  final BDORegion region;
  final TradeMarketTemplateViewController controller;

  const _RecipeCompareBody({required this.region, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cheapest = controller.cheapestVariant;
    return PageBase(
      children: [
        for (final variant in controller.variants)
          _VariantCard(
            region: region,
            controller: controller,
            variant: variant,
            cheapest: identical(variant, cheapest),
          ),
      ],
    );
  }
}

class _VariantCard extends StatelessWidget {
  final BDORegion region;
  final TradeMarketTemplateViewController controller;
  final TradeMarketRecipeVariant variant;
  final bool cheapest;

  const _VariantCard({
    required this.region,
    required this.controller,
    required this.variant,
    required this.cheapest,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = controller.variantTotal(variant);
    final extra = controller.variantExtraCost(variant);
    return Card(
      margin: const EdgeInsets.all(4.0),
      // 최저가 제작법만 테두리로 구분한다.
      shape: cheapest
          ? RoundedRectangleBorder(
              side: BorderSide(color: scheme.primary, width: 2),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _variantName(context),
                    style: TextTheme.of(context).titleMedium,
                  ),
                ),
                if (cheapest)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _Badge(
                      label: context.tr("trade market.templates.cheapest"),
                    ),
                  ),
                Text(
                  total == null ? "-" : total.format(),
                  style: TextTheme.of(context)
                      .titleMedium
                      ?.copyWith(color: cheapest ? scheme.primary : null),
                ),
              ],
            ),
            if (extra != null && extra > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  context.tr(
                    "trade market.templates.extra cost",
                    args: [extra.format()],
                  ),
                  style: TextTheme.of(context).bodySmall,
                ),
              ),
            const SizedBox(height: 8),
            for (final item in variant.items)
              _RecipeItemRow(
                region: region,
                controller: controller,
                item: item,
              ),
          ],
        ),
      ),
    );
  }

  /// 빌트인 제작법 이름은 i18n 키다.
  String _variantName(BuildContext context) {
    final name = variant.name;
    return name.tr() == name ? name : name.tr();
  }
}

/// 제작법 안의 재료 한 줄. 슬롯이면 후보 중 최저가로 뽑힌 아이템을 보여준다.
class _RecipeItemRow extends StatelessWidget {
  final BDORegion region;
  final TradeMarketTemplateViewController controller;
  final TradeMarketTemplateItem item;

  const _RecipeItemRow({
    required this.region,
    required this.controller,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = item.slotResolution;
    final candidates = controller.slotCandidates[item] ?? const [];
    final cost = item.totalCost;
    final inStock = controller.inStock(item);
    return Opacity(
      opacity: inStock ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${_name(context)} × ${item.quantity}"),
                  if (item.slot != null)
                    Text(
                      resolved == null
                          ? context.tr("trade market.templates.no candidate")
                          : context.tr(
                              "trade market.templates.cheapest of candidates",
                              args: [candidates.length.toString()],
                            ),
                      style: TextTheme.of(context).bodySmall,
                    )
                  else if (!item.needsMarketPrice)
                    Text(
                      context.tr("trade market.templates.off market"),
                      style: TextTheme.of(context).bodySmall,
                    ),
                ],
              ),
            ),
            Text(cost == null ? "-" : cost.format()),
          ],
        ),
      ),
    );
  }

  String _name(BuildContext context) {
    // 슬롯은 자리 이름 대신 실제로 골라진 아이템 이름을 보여준다.
    final resolved = item.slotResolution;
    if (resolved != null) {
      return _nameOf(context, resolved);
    }
    final slot = item.slot;
    if (slot != null) {
      return slot.label.tr() == slot.label ? slot.label : slot.label.tr();
    }
    return _nameOf(context, item);
  }

  String _nameOf(BuildContext context, TradeMarketTemplateItem target) {
    final code = target.code;
    if (code == null) {
      final name = target.customName ?? "";
      return name.tr() == name ? name : name.tr();
    }
    return context.itemName(code.toString(), target.enhancementLevel);
  }
}

/// 계산 조건(숙련도·수수료)을 화면에 노출한다.
/// 조건이 안 보이면 수치가 이상할 때 원인을 찾을 수 없다.
///
/// 숙련도는 생활별 전역 설정이고 수수료는 템플릿별 옵션이라 **영향 범위가 다르다.**
/// 같은 자리에서 수정하므로 그 차이를 문구로 알린다.
class _ConditionChips extends StatelessWidget {
  final TradeMarketTemplateViewController controller;

  const _ConditionChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    final template = controller.template;
    if (template == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          if (template.lifeskill != TradeMarketLifeskill.none)
            ActionChip(
              avatar: const Icon(Icons.local_fire_department, size: 18),
              label: Text(_masteryLabel(context, template)),
              onPressed: () => _editMastery(context),
            ),
          // 미적용 상태에서도 칩을 띄운다. 안 그러면 수수료를 켤 방법이 없다.
          ActionChip(
            avatar: const Icon(Icons.receipt_long, size: 18),
            label: Text(controller.taxApplied
                ? context.tr("trade market.templates.tax chip on")
                : context.tr("trade market.templates.tax chip off")),
            // 빌트인은 읽기 전용이라 조건을 바꿀 수 없다.
            onPressed: controller.isBuiltIn ? null : () => _editTax(context),
          ),
        ],
      ),
    );
  }

  String _masteryLabel(BuildContext context, TradeMarketTemplate template) {
    final mastery = context.tr(
      "trade market.templates.mastery chip",
      namedArgs: {
        "skill": context.tr(
            "trade market.templates.lifeskill ${template.lifeskill.name}"),
        "value": controller.mastery.toString(),
      },
    );
    final multiplier = context.tr(
      "trade market.templates.mastery multiplier",
      args: [controller.outputMultiplier.toStringAsFixed(2)],
    );
    return "$mastery · $multiplier";
  }

  Future<void> _editMastery(BuildContext context) async {
    final field = TextEditingController(text: controller.mastery.toString());
    final value = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr("trade market.templates.mastery edit title")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: field,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d{0,4}')),
              ],
            ),
            const SizedBox(height: 12),
            // 숙련도는 전역 값이라 다른 템플릿의 수치도 함께 바뀐다. 반드시 알린다.
            Text(
              context.tr("trade market.templates.mastery scope notice"),
              style: TextTheme.of(context).bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.tr("cancel")),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(int.tryParse(field.text) ?? 0),
            child: Text(context.tr("confirm")),
          ),
        ],
      ),
    );
    field.dispose();
    if (value != null) {
      await controller.updateMastery(value);
    }
  }

  Future<void> _editTax(BuildContext context) async {
    final result = await showDialog<TradeMarketTaxOption>(
      context: context,
      builder: (context) => _TaxDialog(initial: controller.template!.tax),
    );
    if (result != null) {
      await controller.updateTax(result);
    }
  }
}

/// 수수료 조건 편집. 숙련도와 달리 **이 템플릿에만** 적용된다.
class _TaxDialog extends StatefulWidget {
  final TradeMarketTaxOption initial;

  const _TaxDialog({required this.initial});

  @override
  State<_TaxDialog> createState() => _TaxDialogState();
}

class _TaxDialogState extends State<_TaxDialog> {
  late bool _enabled = widget.initial.enabled;
  late bool _valuePackage = widget.initial.valuePackage;
  late bool _merchantRing = widget.initial.merchantRing;
  late bool _crescentPass = widget.initial.crescentPass;
  late final TextEditingController _fame =
      TextEditingController(text: widget.initial.familyFame.toString());

  @override
  void dispose() {
    _fame.dispose();
    super.dispose();
  }

  TradeMarketTaxOption get _value => TradeMarketTaxOption(
        enabled: _enabled,
        valuePackage: _valuePackage,
        merchantRing: _merchantRing,
        crescentPass: _crescentPass,
        familyFame: int.tryParse(_fame.text) ?? 0,
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr("trade market.templates.tax edit title")),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr("trade market.templates.tax enabled")),
              value: _enabled,
              onChanged: (value) => setState(() => _enabled = value),
            ),
            if (_enabled) ...[
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title:
                    Text(context.tr("trade market.templates.tax value package")),
                value: _valuePackage,
                onChanged: (value) =>
                    setState(() => _valuePackage = value ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title:
                    Text(context.tr("trade market.templates.tax merchant ring")),
                value: _merchantRing,
                onChanged: (value) =>
                    setState(() => _merchantRing = value ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title:
                    Text(context.tr("trade market.templates.tax crescent pass")),
                value: _crescentPass,
                onChanged: (value) =>
                    setState(() => _crescentPass = value ?? false),
              ),
              TextField(
                controller: _fame,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,5}')),
                ],
                decoration: InputDecoration(
                  labelText:
                      context.tr("trade market.templates.tax family fame"),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Text(
                context.tr(
                  "trade market.templates.receipt rate",
                  args: [(_value.receiptRate * 100).toStringAsFixed(1)],
                ),
                style: TextTheme.of(context).titleSmall,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              context.tr("trade market.templates.tax scope notice"),
              style: TextTheme.of(context).bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.tr("cancel")),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_value),
          child: Text(context.tr("confirm")),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  final TradeMarketTemplateViewController controller;

  const _Summary({required this.controller});

  @override
  Widget build(BuildContext context) {
    final difference = controller.difference;
    final Color differenceColor = difference > 0
        ? Colors.green.shade400
        : (difference < 0 ? Colors.red : Colors.orange);
    final taxApplied = controller.taxApplied;
    return Card(
      margin: const EdgeInsets.all(4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _SummaryRow(
              label: context.tr("trade market.templates.materials total"),
              value: controller.materialsTotal.format(),
            ),
            _SummaryRow(
              // 수수료를 적용하는 템플릿에서만 세전임을 밝힌다.
              label: taxApplied
                  ? context.tr("trade market.templates.results total pretax")
                  : context.tr("trade market.templates.results total"),
              value: controller.resultsTotal.format(),
            ),
            // 수수료 줄은 적용된 템플릿에서만 노출한다. 차익이 왜 줄었는지 보여야 한다.
            if (taxApplied)
              _SummaryRow(
                label: context.tr(
                  "trade market.templates.receipt rate",
                  args: [
                    (controller.template!.tax.receiptRate * 100)
                        .toStringAsFixed(1)
                  ],
                ),
                value: "-${controller.marketFee.format()}",
                valueColor: Theme.of(context).colorScheme.error,
              ),
            const Divider(),
            _SummaryRow(
              label: taxApplied
                  ? context.tr("trade market.templates.difference after tax")
                  : context.tr("trade market.templates.difference"),
              value: difference.format(),
              valueColor: differenceColor,
              emphasize: true,
            ),
            // 세전 차익은 아래에 작게 붙인다. 같은 크기로 두면 결론이 흐려진다.
            if (taxApplied)
              _SummaryRow(
                label:
                    context.tr("trade market.templates.difference before tax"),
                value: controller.differenceBeforeTax.format(),
                small: true,
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
  final bool small;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = emphasize
        ? TextTheme.of(context).titleMedium
        : (small
            ? TextTheme.of(context).bodySmall
            : TextTheme.of(context).bodyLarge);
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

/// 타입 공통 아이템 행.
///
/// 거래소 아이템·거래 불가 아이템·구성 요소로 계산되는 아이템을 모두 한 행으로 그린다.
class _ItemTile extends StatelessWidget {
  final BDORegion region;
  final TradeMarketTemplateItem item;
  final bool inStock;
  final bool highlight;
  final String? subtitle;
  final int? trailingValue;

  const _ItemTile({
    required this.region,
    required this.item,
    required this.inStock,
    this.highlight = false,
    this.subtitle,
    this.trailingValue,
  });

  @override
  Widget build(BuildContext context) {
    final code = item.code;
    final scheme = Theme.of(context).colorScheme;
    return Opacity(
      // 못 사는 항목이 시선을 끌지 않도록 행 전체를 흐리게 한다.
      opacity: inStock ? 1.0 : 0.5,
      child: Card(
        margin: const EdgeInsets.all(4.0),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: Dimens.listTileContentsPadding(),
          leading: code == null
              ? const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.help_outline),
                )
              : BdoItemImage(
                  code: code.toString(),
                  enhancementLevel: item.enhancementLevel,
                ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  "${_name(context)} × ${item.quantity}",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!item.needsMarketPrice) ...[
                const SizedBox(width: 6),
                _Badge(label: context.tr("trade market.templates.off market")),
              ],
            ],
          ),
          subtitle: subtitle == null
              ? null
              : Text(
                  subtitle!,
                  style: TextTheme.of(context).bodyMedium?.copyWith(
                        color: highlight ? scheme.primary : null,
                        fontWeight: highlight ? FontWeight.bold : null,
                      ),
                ),
          trailing: _trailing(context),
          onTap: code == null
              ? null
              : () {
                  context.goWithGa("/trade-market/${region.name}/detail/$code");
                },
        ),
      ),
    );
  }

  String _name(BuildContext context) {
    final code = item.code;
    if (code == null) {
      // 빌트인의 사용자 정의 아이템 이름은 i18n 키로 들어온다.
      final name = item.customName ?? "";
      return name.tr() == name ? name : name.tr();
    }
    return context.itemName(code.toString(), item.enhancementLevel);
  }

  Widget? _trailing(BuildContext context) {
    final value = trailingValue;
    if (value == null) {
      return null;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value.format()),
        // 싸도 물량이 없으면 못 사므로 재고는 항상 보여준다.
        if (item.needsMarketPrice)
          Text(
            inStock
                ? context.tr(
                    "trade market.templates.stock and yield",
                    namedArgs: {
                      "stock": (item.marketPrice?.currentStock ?? 0).format(),
                      "yield": item.yieldAmount.toString(),
                    },
                  )
                : context.tr("trade market.templates.out of stock"),
            style: TextTheme.of(context).bodySmall?.copyWith(
                  color: inStock ? null : Theme.of(context).colorScheme.error,
                ),
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextTheme.of(context)
            .labelSmall
            ?.copyWith(color: scheme.onSecondaryContainer),
      ),
    );
  }
}
