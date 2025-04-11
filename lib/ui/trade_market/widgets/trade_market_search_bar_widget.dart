import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:karanda/route.dart';
import 'package:karanda/ui/trade_market/controllers/trade_market_search_bar_controller.dart';
import 'package:provider/provider.dart';

class TradeMarketSearchBarWidget extends StatelessWidget {
  const TradeMarketSearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TradeMarketSearchBarController(
        itemInfoService: context.read(),
        settingsService: context.read(),
        router: router,
      ),
      child: Consumer(
        builder: (context, TradeMarketSearchBarController controller, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Autocomplete<String>(
                fieldViewBuilder:
                    (context, textController, focusNode, onSubmit) {
                  controller.textEditingController = textController;
                  return TextField(
                    controller: controller.textEditingController,
                    focusNode: focusNode,
                    textInputAction: TextInputAction.go,
                    maxLength: 40,
                    onSubmitted: (value) {
                      if (value.replaceAll(" ", "").isNotEmpty) {
                        controller.onSubmitted(
                          value.replaceAll(" ", ""),
                          context.locale,
                          onSubmit,
                        );
                      } else {
                        onSubmit();
                      }
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      counter: Container(),
                      hintText: context.tr("trade market.search hint"),
                      labelText: context.tr("trade market.search"),
                    ),
                  );
                },
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.replaceAll(" ", "").isNotEmpty) {
                    return controller.getOptions(
                      textEditingValue.text.replaceAll(" ", ""),
                      context.locale,
                    );
                  }
                  return const [];
                },
                optionsViewBuilder: (
                  BuildContext context,
                  AutocompleteOnSelected<String> onSelected,
                  Iterable<String> options,
                ) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Card(
                      margin: const EdgeInsets.only(top: 2.0, right: 8.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.sizeOf(context).height / 2,
                          maxWidth: constraints.biggest.width,
                        ),
                        child: _OptionListBuilder(
                          options: options,
                          onSelected: onSelected,
                        ),
                      ),
                    ),
                  );
                },
                onSelected: (value) {
                  if (value.trim().isNotEmpty) {
                    controller.onSelected(value.trim(), context.locale);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _OptionListBuilder extends StatelessWidget {
  final Iterable<String> options;
  final AutocompleteOnSelected<String> onSelected;

  const _OptionListBuilder({
    super.key,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: options.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final option = options.elementAt(index);
        final selected = AutocompleteHighlightedOption.of(context) == index;
        return _ItemTile(
          title: RawAutocomplete.defaultStringForOption(option),
          selected: selected,
          onTap: () => onSelected(option),
        );
      },
    );
  }
}

class _ItemTile extends StatelessWidget {
  final String title;
  final bool selected;
  final void Function() onTap;

  const _ItemTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (selected) {
      SchedulerBinding.instance.addPostFrameCallback(
        (_) => Scrollable.ensureVisible(context, alignment: 0.5),
      );
    }
    return ListTile(
      title: Text(title),
      selected: selected,
      onTap: onTap,
      selectedTileColor: Theme.of(context).focusColor,
    );
  }
}
