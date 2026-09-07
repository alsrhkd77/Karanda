import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/bdo_item_info.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:karanda/ui/core/ui/bdo_item_image.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/trade_market/templates/controllers/trade_market_template_editor_controller.dart';
import 'package:karanda/utils/extension/build_context_extension.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';
import 'package:provider/provider.dart';

class TradeMarketTemplateEditorPage extends StatelessWidget {
  final BDORegion region;
  final String? templateId;

  const TradeMarketTemplateEditorPage({
    super.key,
    required this.region,
    this.templateId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TradeMarketTemplateEditorController(
        tradeMarketService: context.read(),
        itemInfoService: context.read(),
        templateId: templateId,
      ),
      child: Consumer(
        builder:
            (context, TradeMarketTemplateEditorController controller, child) {
          return Scaffold(
            appBar: KarandaAppBar(
              title: controller.isEditMode
                  ? context.tr("trade market.templates.edit template")
                  : context.tr("trade market.templates.new template"),
              icon: FontAwesomeIcons.scaleUnbalanced,
              actions: [
                if (controller.isEditMode)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip:
                        context.tr("trade market.templates.delete template"),
                    onPressed: () => _onDelete(context, controller),
                  ),
                IconButton(
                  icon: const Icon(Icons.check),
                  tooltip: context.tr("trade market.templates.save"),
                  onPressed: controller.canSave
                      ? () => _onSave(context, controller)
                      : null,
                ),
              ],
            ),
            body: controller.loading
                ? const LoadingIndicator()
                : const _EditorBody(),
          );
        },
      ),
    );
  }

  Future<void> _onSave(
    BuildContext context,
    TradeMarketTemplateEditorController controller,
  ) async {
    final saved = await controller.save();
    if (saved && context.mounted) {
      context.goWithGa("/trade-market");
    }
  }

  Future<void> _onDelete(
    BuildContext context,
    TradeMarketTemplateEditorController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr("trade market.templates.delete template")),
        content:
            Text(context.tr("trade market.templates.delete template confirm")),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.tr("cancel")),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.tr("confirm")),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.delete();
      if (context.mounted) {
        context.goWithGa("/trade-market");
      }
    }
  }
}

class _EditorBody extends StatelessWidget {
  const _EditorBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TradeMarketTemplateEditorController>();
    return PageBase(
      children: [
        TextField(
          controller: controller.nameController,
          maxLength: 30,
          decoration: InputDecoration(
            labelText: context.tr("trade market.templates.template name"),
            counter: const SizedBox.shrink(),
          ),
          onChanged: (_) => controller.refresh(),
        ),
        const SizedBox(height: 8),
        const _TypeSelector(),
        if (controller.usesTaxAndLifeskill) const _ProfitOptions(),
        const SizedBox(height: 8),
        if (controller.usesVariants) ...[
          const _VariantEditor(),
        ] else ...[
          const _ItemPicker(),
          const _CustomItemAdder(),
        ],
        if (!controller.usesVariants && controller.atCapacity)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              context.tr("trade market.templates.max items"),
              style: const TextStyle(color: Colors.orange),
            ),
          ),
        const SizedBox(height: 8),
        if (!controller.usesVariants)
          if (controller.items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(context.tr("trade market.templates.empty items")),
              ),
            )
          else
            ...controller.items.map((item) => _EditorItemTile(
                  key: ObjectKey(item),
                  item: item,
                )),
      ],
    );
  }
}

/// 템플릿 종류 선택. 종류에 따라 아래 입력 항목이 바뀐다.
class _TypeSelector extends StatelessWidget {
  const _TypeSelector();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TradeMarketTemplateEditorController>();
    const selectable = TradeMarketTemplateType.values;
    return Card(
      margin: const EdgeInsets.all(4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr("trade market.templates.template type"),
              style: TextTheme.of(context).titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<TradeMarketTemplateType>(
              showSelectedIcon: false,
              segments: selectable
                  .map((type) => ButtonSegment(
                        value: type,
                        label: Text(
                          context.tr("trade market.templates.type ${type.name}"),
                        ),
                      ))
                  .toList(),
              selected: {controller.type},
              onSelectionChanged: (selection) {
                controller.updateType(selection.first);
              },
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(
                  "trade market.templates.type ${controller.type.name} description"),
              style: TextTheme.of(context).bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// 차익형 전용 옵션 — 생활 종류와 거래소 수수료 조건.
class _ProfitOptions extends StatelessWidget {
  const _ProfitOptions();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TradeMarketTemplateEditorController>();
    return Card(
      margin: const EdgeInsets.all(4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  context.tr("trade market.templates.lifeskill"),
                  style: TextTheme.of(context).titleSmall,
                ),
                const Spacer(),
                DropdownButton<TradeMarketLifeskill>(
                  value: controller.lifeskill,
                  isDense: true,
                  items: TradeMarketLifeskill.values
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(context.tr(
                                "trade market.templates.lifeskill ${value.name}")),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.updateLifeskill(value);
                    }
                  },
                ),
              ],
            ),
            const Divider(),
            Text(
              context.tr("trade market.templates.tax option"),
              style: TextTheme.of(context).titleSmall,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr("trade market.templates.tax enabled")),
              value: controller.taxEnabled,
              onChanged: controller.updateTaxEnabled,
            ),
            if (controller.taxEnabled) ...[
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title:
                    Text(context.tr("trade market.templates.tax value package")),
                value: controller.valuePackage,
                onChanged: (value) =>
                    controller.updateValuePackage(value ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title:
                    Text(context.tr("trade market.templates.tax merchant ring")),
                value: controller.merchantRing,
                onChanged: (value) =>
                    controller.updateMerchantRing(value ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title:
                    Text(context.tr("trade market.templates.tax crescent pass")),
                value: controller.crescentPass,
                onChanged: (value) =>
                    controller.updateCrescentPass(value ?? false),
              ),
              SizedBox(
                width: 160,
                child: TextField(
                  controller: controller.familyFameController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d{0,5}')),
                  ],
                  decoration: InputDecoration(
                    labelText:
                        context.tr("trade market.templates.tax family fame"),
                  ),
                  onChanged: (_) => controller.refresh(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(
                  "trade market.templates.receipt rate",
                  args: [
                    (TradeMarketTaxOption(
                              enabled: controller.taxEnabled,
                              valuePackage: controller.valuePackage,
                              merchantRing: controller.merchantRing,
                              crescentPass: controller.crescentPass,
                              familyFame: int.tryParse(
                                      controller.familyFameController.text) ??
                                  0,
                            ).receiptRate *
                            100)
                        .toStringAsFixed(1)
                  ],
                ),
                style: TextTheme.of(context).titleSmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ItemPicker extends StatefulWidget {
  const _ItemPicker();

  @override
  State<_ItemPicker> createState() => _ItemPickerState();
}

class _ItemPickerState extends State<_ItemPicker> {
  TextEditingController? _fieldController;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<TradeMarketTemplateEditorController>();
    return LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<BDOItemInfo>(
          displayStringForOption: (option) => option.name(context.locale),
          optionsBuilder: (textEditingValue) {
            return controller.searchItems(
                textEditingValue.text, context.locale);
          },
          fieldViewBuilder:
              (context, textController, focusNode, onFieldSubmitted) {
            _fieldController = textController;
            return TextField(
              controller: textController,
              focusNode: focusNode,
              maxLength: 40,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.add),
                counter: const SizedBox.shrink(),
                labelText: context.tr("trade market.templates.add item"),
                hintText: context.tr("trade market.search hint"),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Card(
                margin: const EdgeInsets.only(top: 2.0, right: 8.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height / 2,
                    maxWidth: constraints.biggest.width,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      final selected =
                          AutocompleteHighlightedOption.of(context) == index;
                      if (selected) {
                        SchedulerBinding.instance.addPostFrameCallback((_) {
                          Scrollable.ensureVisible(context, alignment: 0.5);
                        });
                      }
                      return ListTile(
                        selected: selected,
                        selectedTileColor: Theme.of(context).focusColor,
                        leading: BdoItemImage(code: option.code),
                        title: Text(option.name(context.locale)),
                        // 거래 불가 아이템은 가격을 직접 넣어야 하므로 미리 알린다.
                        subtitle: option.tradeAble
                            ? null
                            : Text(
                                context.tr("trade market.templates.off market")),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          onSelected: (option) {
            final added = controller.addItem(option);
            _fieldController?.clear();
            if (!added && context.mounted) {
              _showFailed(context);
            }
          },
        );
      },
    );
  }
}

void _showFailed(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(context.tr("trade market.templates.add item failed")),
      duration: const Duration(seconds: 2),
    ),
  );
}

/// 카탈로그에 아예 없는 아이템을 이름·가격으로 직접 넣는다.
/// 제작법 재료 중에는 거래소는 물론 아이템 목록에도 없는 것이 있다.
class _CustomItemAdder extends StatefulWidget {
  const _CustomItemAdder();

  @override
  State<_CustomItemAdder> createState() => _CustomItemAdderState();
}

class _CustomItemAdderState extends State<_CustomItemAdder> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  bool _expanded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _add() {
    final controller = context.read<TradeMarketTemplateEditorController>();
    final added = controller.addCustomItem(
      _nameController.text,
      int.tryParse(_priceController.text.replaceAll(",", "")) ?? 0,
    );
    if (!added) {
      _showFailed(context);
      return;
    }
    _nameController.clear();
    _priceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (!_expanded) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          icon: const Icon(Icons.edit_note),
          label: Text(context.tr("trade market.templates.add custom item")),
          onPressed: () => setState(() => _expanded = true),
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.all(4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr("trade market.templates.custom item hint"),
              style: TextTheme.of(context).bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _nameController,
                    maxLength: 40,
                    decoration: InputDecoration(
                      counter: const SizedBox.shrink(),
                      labelText:
                          context.tr("trade market.templates.custom item name"),
                    ),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d{0,15}')),
                    ],
                    decoration: InputDecoration(
                      labelText:
                          context.tr("trade market.templates.custom item price"),
                    ),
                  ),
                ),
                FilledButton.tonal(
                  onPressed: _add,
                  child:
                      Text(context.tr("trade market.templates.custom item add")),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _expanded = false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


/// 제작법 비교형 편집. 제작법마다 이름과 재료 목록을 따로 갖는다.
class _VariantEditor extends StatelessWidget {
  const _VariantEditor();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TradeMarketTemplateEditorController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final variant in controller.variants)
          _VariantSection(key: ObjectKey(variant), variant: variant),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: Text(context.tr("trade market.templates.add variant")),
            onPressed: controller.addVariant,
          ),
        ),
      ],
    );
  }
}

class _VariantSection extends StatelessWidget {
  final TemplateEditorVariant variant;

  const _VariantSection({super.key, required this.variant});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TradeMarketTemplateEditorController>();
    return Card(
      margin: const EdgeInsets.all(4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: variant.nameController,
                    maxLength: 30,
                    decoration: InputDecoration(
                      counter: const SizedBox.shrink(),
                      labelText:
                          context.tr("trade market.templates.variant name"),
                    ),
                    onChanged: (_) => controller.refresh(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => controller.removeVariant(variant),
                ),
              ],
            ),
            // 빌트인에서 복제해 온 슬롯·구성 요소는 편집할 수 없지만 저장 시 그대로 유지된다.
            for (final locked in variant.locked)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_outline, size: 18),
                title: Text(_lockedName(context, locked)),
                subtitle:
                    Text(context.tr("trade market.templates.locked item")),
              ),
            _VariantItemPicker(variant: variant),
            for (final item in variant.items)
              _VariantItemRow(
                key: ObjectKey(item),
                variant: variant,
                item: item,
              ),
          ],
        ),
      ),
    );
  }

  String _lockedName(BuildContext context, TradeMarketTemplateItem item) {
    final slot = item.slot;
    if (slot != null) {
      return slot.label.tr() == slot.label ? slot.label : slot.label.tr();
    }
    final name = item.customName ?? "";
    if (name.isNotEmpty) {
      return name.tr() == name ? name : name.tr();
    }
    final code = item.code;
    return code == null
        ? ""
        : context.itemName(code.toString(), item.enhancementLevel);
  }
}

class _VariantItemPicker extends StatefulWidget {
  final TemplateEditorVariant variant;

  const _VariantItemPicker({required this.variant});

  @override
  State<_VariantItemPicker> createState() => _VariantItemPickerState();
}

class _VariantItemPickerState extends State<_VariantItemPicker> {
  TextEditingController? _fieldController;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<TradeMarketTemplateEditorController>();
    return Autocomplete<BDOItemInfo>(
      displayStringForOption: (option) => option.name(context.locale),
      optionsBuilder: (value) =>
          controller.searchItems(value.text, context.locale),
      fieldViewBuilder: (context, textController, focusNode, onSubmitted) {
        _fieldController = textController;
        return TextField(
          controller: textController,
          focusNode: focusNode,
          maxLength: 40,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.add),
            counter: const SizedBox.shrink(),
            labelText: context.tr("trade market.templates.add item"),
          ),
        );
      },
      onSelected: (option) {
        final added = controller.addItemToVariant(widget.variant, option);
        _fieldController?.clear();
        if (!added && context.mounted) {
          _showFailed(context);
        }
      },
    );
  }
}

class _VariantItemRow extends StatelessWidget {
  final TemplateEditorVariant variant;
  final TemplateEditorItem item;

  const _VariantItemRow({
    super.key,
    required this.variant,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.read<TradeMarketTemplateEditorController>();
    final code = item.code;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              code == null
                  ? (item.customName ?? "")
                  : context.itemName(code.toString(), item.enhancementLevel),
            ),
          ),
          _NumberField(
            controller: item.quantityController,
            label: context.tr("trade market.templates.quantity"),
            maxDigits: 5,
            width: 90,
          ),
          if (item.isOffMarket) ...[
            const SizedBox(width: 8),
            _NumberField(
              controller: item.priceController,
              label: context.tr("trade market.templates.custom item price"),
              maxDigits: 15,
              width: 150,
            ),
          ],
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => controller.removeItemFromVariant(variant, item),
          ),
        ],
      ),
    );
  }
}

class _EditorItemTile extends StatelessWidget {
  final TemplateEditorItem item;

  const _EditorItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TradeMarketTemplateEditorController>();
    final code = item.code;
    final maxEnhancement = code == null ? 0 : controller.maxEnhancementOf(code);
    return Card(
      margin: const EdgeInsets.all(4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (code == null)
                  const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(Icons.help_outline),
                  )
                else
                  BdoItemImage(
                    code: code.toString(),
                    enhancementLevel: item.enhancementLevel,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    code == null
                        ? (item.customName ?? "")
                        : context.itemName(
                            code.toString(), item.enhancementLevel),
                    style: TextTheme.of(context).bodyLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => controller.removeItem(item),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (controller.usesQuantity)
                  _NumberField(
                    controller: item.quantityController,
                    label: context.tr("trade market.templates.quantity"),
                    maxDigits: 3,
                  ),
                if (controller.usesYield)
                  _NumberField(
                    controller: item.yieldController,
                    label: context.tr("trade market.templates.yield amount"),
                    maxDigits: 4,
                  ),
                // 거래소 시세가 없는 아이템만 가격을 직접 받는다.
                if (item.isOffMarket)
                  _NumberField(
                    controller: item.priceController,
                    label:
                        context.tr("trade market.templates.custom item price"),
                    maxDigits: 15,
                    width: 180,
                  ),
                if (maxEnhancement > 0)
                  _EnhancementSelector(
                    item: item,
                    maxEnhancement: maxEnhancement,
                  ),
                if (controller.usesRole)
                  SegmentedButton<TradeMarketTemplateItemRole>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: TradeMarketTemplateItemRole.material,
                        label:
                            Text(context.tr("trade market.templates.material")),
                      ),
                      ButtonSegment(
                        value: TradeMarketTemplateItemRole.result,
                        label:
                            Text(context.tr("trade market.templates.result")),
                      ),
                    ],
                    selected: {item.role},
                    onSelectionChanged: (selection) {
                      controller.updateRole(item, selection.first);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxDigits;
  final double width;

  const _NumberField({
    required this.controller,
    required this.label,
    required this.maxDigits,
    this.width = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('^\\d{0,$maxDigits}')),
        ],
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 8.0,
          ),
        ),
      ),
    );
  }
}

class _EnhancementSelector extends StatelessWidget {
  final TemplateEditorItem item;
  final int maxEnhancement;

  const _EnhancementSelector({
    required this.item,
    required this.maxEnhancement,
  });

  String _label(BuildContext context, int level) {
    if (level == 0) {
      return context.tr("trade market.templates.base level");
    }
    return context
        .itemInfo(item.code.toString())
        .enhancementLevelToString(level)
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: item.enhancementLevel,
      isDense: true,
      items: List.generate(maxEnhancement + 1, (level) {
        return DropdownMenuItem(
          value: level,
          child: Text(_label(context, level)),
        );
      }),
      onChanged: (level) {
        if (level == null) {
          return;
        }
        final controller =
            context.read<TradeMarketTemplateEditorController>();
        final applied = controller.updateEnhancement(item, level);
        if (!applied) {
          _showFailed(context);
        }
      },
    );
  }
}
