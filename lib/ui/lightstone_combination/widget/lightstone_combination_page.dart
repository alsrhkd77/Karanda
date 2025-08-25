import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/data_source/lightstone_combination_data_source.dart';
import 'package:karanda/model/lightstone_combination/combination.dart';
import 'package:karanda/repository/lightstone_combination_repository.dart';
import 'package:karanda/ui/core/ui/karanda_app_bar.dart';
import 'package:karanda/ui/core/ui/loading_indicator.dart';
import 'package:karanda/ui/core/ui/page_base.dart';
import 'package:karanda/ui/lightstone_combination/controller/lightstone_combination_controller.dart';
import 'package:karanda/utils/extension/build_context_extension.dart';
import 'package:provider/provider.dart';

class LightstoneCombinationPage extends StatelessWidget {
  const LightstoneCombinationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => LightstoneCombinationDataSource()),
        Provider(
          create: (context) => LightstoneCombinationRepository(
            lightstoneCombinationDataSource: context.read(),
            itemInfoDataSource: context.read(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => LightstoneCombinationController(
            repository: context.read(),
          )..getData(),
        ),
      ],
      builder: (context, child) {
        return Scaffold(
          appBar: KarandaAppBar(
            title: context.tr("lightstoneCombination.lightstoneCombination"),
            icon: FontAwesomeIcons.splotch,
          ),
          body: Consumer(
            builder:
                (context, LightstoneCombinationController controller, child) {
              if (controller.autocompleteOptionsKR.isEmpty ||
                  controller.autocompleteOptionsEN.isEmpty) {
                return LoadingIndicator();
              }
              final width = MediaQuery.sizeOf(context).width;
              return PageBase(
                width: width,
                children: [
                  _SearchBar(
                    buildOptions: (keyword) {
                      return controller.buildOptions(keyword, context.locale);
                    },
                    addKeyword: controller.addKeyword,
                  ),
                  _Options(
                    width: width,
                    viewAmplified: controller.viewAmplified,
                    useAndFilter: controller.useAndFilter,
                    setViewAmplified: controller.setViewAmplified,
                    setAndFilter: controller.setAndFilter,
                  ),
                  _Keywords(
                    data: controller.keywords,
                    remove: controller.removeKeyword,
                  ),
                  ...controller.combination.isEmpty
                      ? [
                          Container(
                            alignment: Alignment.bottomCenter,
                            height: MediaQuery.sizeOf(context).height * 0.3,
                            child: Text(
                              context.tr("lightstoneCombination.empty"),
                            ),
                          ),
                        ]
                      : controller.combination.map((data) {
                          return _CombinationCard(
                            width: width,
                            combination: data,
                          );
                        }),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _CombinationCard extends StatelessWidget {
  final double width;
  final Combination combination;

  const _CombinationCard({
    super.key,
    required this.width,
    required this.combination,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                combination.getName(locale),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Flex(
              direction: width < 780 ? Axis.vertical : Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: ListTile(
                    titleTextStyle: TextTheme.of(context)
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    title: Text(
                      context.tr("lightstoneCombination.combinationEffect"),
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: combination.effects.map((effect) {
                          return Text(effect.getText(locale));
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: ListTile(
                    titleTextStyle: TextTheme.of(context)
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    title: Text(
                      context.tr("lightstoneCombination.mixedEffect"),
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: combination.totalEffects.map((effect) {
                          return Text(effect.getText(locale));
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: ListTile(
                    titleTextStyle: TextTheme.of(context)
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    title: Text(
                      context.tr("lightstoneCombination.combination"),
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: combination.lightstones.map((stone) {
                          return Tooltip(
                            message: stone.effect.getText(locale),
                            child: Text(
                              context.itemName(stone.code.toString()),
                              style: TextStyle(color: stone.color),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final Iterable<String> Function(String) buildOptions;
  final void Function(String) addKeyword;

  const _SearchBar({
    super.key,
    required this.buildOptions,
    required this.addKeyword,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete(
      fieldViewBuilder: (context, textController, focusNode, onSubmit) {
        return TextField(
          controller: textController,
          focusNode: focusNode,
          maxLength: 40,
          onSubmitted: (String value) {
            onSubmit();
            addKeyword(textController.text.trim());
            textController.clear();
            FocusScope.of(context).requestFocus(focusNode);
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            suffix: TextButton(
              onPressed: () {
                addKeyword(textController.text.trim());
                textController.clear();
                FocusScope.of(context).requestFocus(focusNode);
              },
              child: Text(
                context.tr("lightstoneCombination.searchBar.add"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            labelText: context.tr("lightstoneCombination.searchBar.label"),
            hintText: context.tr("lightstoneCombination.searchBar.hint"),
            counter: const SizedBox(),
          ),
        );
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.trim().isEmpty) {
          return const Iterable<String>.empty();
        }
        return buildOptions(textEditingValue.text.trim());
      },
      optionsMaxHeight: MediaQuery.sizeOf(context).height / 2,
    );
  }
}

class _Options extends StatelessWidget {
  final double width;
  final bool viewAmplified;
  final bool useAndFilter;
  final void Function(bool?) setViewAmplified;
  final void Function(bool) setAndFilter;

  const _Options({
    super.key,
    required this.width,
    required this.viewAmplified,
    required this.useAndFilter,
    required this.setViewAmplified,
    required this.setAndFilter,
  });

  @override
  Widget build(BuildContext context) {
    if (width < 700) {
      return Column(
        children: [
          Container(
            width: Size.infinite.width,
            padding: EdgeInsets.all(8.0),
            child: _Filter(value: useAndFilter, onChanged: setAndFilter),
          ),
          _ViewAmplified(value: viewAmplified, onChanged: setViewAmplified),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(
            child: _ViewAmplified(
              value: viewAmplified,
              onChanged: setViewAmplified,
            ),
          ),
          _Filter(value: useAndFilter, onChanged: setAndFilter)
        ],
      ),
    );
  }
}

class _ViewAmplified extends StatelessWidget {
  final bool value;
  final void Function(bool?) onChanged;

  const _ViewAmplified({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(value: value, onChanged: onChanged),
      title: Text(context.tr("lightstoneCombination.viewAmplified")),
    );
  }
}

class _Filter extends StatelessWidget {
  final bool value;
  final void Function(bool) onChanged;

  const _Filter({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: SegmentedButton<bool>(
        segments: const <ButtonSegment<bool>>[
          ButtonSegment(
            value: true,
            label: Text("AND"),
            icon: Icon(Icons.join_inner),
          ),
          ButtonSegment(
            value: false,
            label: Text("OR"),
            icon: Icon(Icons.join_full),
          ),
        ],
        selected: <bool>{value},
        onSelectionChanged: (Set<bool> selection) => onChanged(selection.first),
      ),
    );
  }
}

class _Keywords extends StatelessWidget {
  final Set<String> data;
  final void Function(String) remove;

  const _Keywords({super.key, required this.data, required this.remove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        children: data.map((keyword) {
          return Chip(
            label: Text(keyword),
            onDeleted: () => remove(keyword),
            focusNode: FocusNode(skipTraversal: true),
          );
        }).toList(),
      ),
    );
  }
}
