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
  const _EditorBody({super.key});

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
        const _ItemPicker(),
        if (controller.atCapacity)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              context.tr("trade market.templates.max items"),
              style: const TextStyle(color: Colors.orange),
            ),
          ),
        const SizedBox(height: 8),
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

class _ItemPicker extends StatefulWidget {
  const _ItemPicker({super.key});

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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      context.tr("trade market.templates.add item failed")),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        );
      },
    );
  }
}

class _EditorItemTile extends StatelessWidget {
  final TemplateEditorItem item;

  const _EditorItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<TradeMarketTemplateEditorController>();
    final itemInfo = context.itemInfo(item.code.toString());
    final maxEnhancement = controller.maxEnhancementOf(item.code);
    return Card(
      margin: const EdgeInsets.all(4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BdoItemImage(
                  code: itemInfo.code,
                  enhancementLevel: item.enhancementLevel,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.itemName(itemInfo.code, item.enhancementLevel),
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
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: item.quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}')),
                    ],
                    decoration: InputDecoration(
                      labelText: context.tr("trade market.templates.quantity"),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                    ),
                  ),
                ),
                if (maxEnhancement > 0)
                  _EnhancementSelector(
                    item: item,
                    maxEnhancement: maxEnhancement,
                  ),
                SegmentedButton<TradeMarketTemplateItemRole>(
                  segments: [
                    ButtonSegment(
                      value: TradeMarketTemplateItemRole.material,
                      label:
                          Text(context.tr("trade market.templates.material")),
                    ),
                    ButtonSegment(
                      value: TradeMarketTemplateItemRole.result,
                      label: Text(context.tr("trade market.templates.result")),
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

class _EnhancementSelector extends StatelessWidget {
  final TemplateEditorItem item;
  final int maxEnhancement;

  const _EnhancementSelector({
    super.key,
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(context.tr("trade market.templates.add item failed")),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }
}
