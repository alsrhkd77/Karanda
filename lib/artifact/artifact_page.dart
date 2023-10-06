import 'package:flutter/scheduler.dart';
import 'package:karanda/artifact/artifact_notifier.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../widgets/default_app_bar.dart';
import '../widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ArtifactPage extends StatefulWidget {
  const ArtifactPage({Key? key}) : super(key: key);

  @override
  State<ArtifactPage> createState() => _ArtifactPageState();
}

class _ArtifactPageState extends State<ArtifactPage> {
  final ScrollController _mainScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = GlobalProperties.scrollViewHorizontalPadding(
        MediaQuery.sizeOf(context).width);
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: const DefaultAppBar(),
        body: ChangeNotifierProvider(
          create: (_) => ArtifactNotifier(),
          child: Consumer<ArtifactNotifier>(
            builder: (_, notifier, __) {
              if (notifier.options.isEmpty) {
                return const LoadingIndicator();
              }
              return CustomScrollView(
                controller: _mainScrollController,
                slivers: [
                  const SliverToBoxAdapter(
                    child: ListTile(
                      leading: Icon(FontAwesomeIcons.splotch),
                      title: TitleText(
                        '광명석 조합식',
                        bold: true,
                      ),
                      trailing: _FilterButton(),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: GlobalProperties.scrollViewVerticalPadding),
                    sliver: const SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _SearchBar(),
                          _KeywordChips(),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    sliver: const _CardList(),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: GlobalProperties.scrollViewVerticalPadding),
                    sliver: const SliverToBoxAdapter(
                      child: _LoadButton(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(FontAwesomeIcons.arrowUp),
          onPressed: () {
            _mainScrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear,
            );
          },
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool filter = context
        .select<ArtifactNotifier, bool>((ArtifactNotifier a) => a.orFilter);
    return IconButton(
      onPressed: context.read<ArtifactNotifier>().changeFilter,
      icon: Icon(
        filter ? Icons.join_full : Icons.join_inner,
      ),
      tooltip: filter ? 'OR' : 'AND',
    );
  }
}

class _LoadButton extends StatelessWidget {
  const _LoadButton({super.key});

  @override
  Widget build(BuildContext context) {
    final int index = context
        .select<ArtifactNotifier, int>((ArtifactNotifier a) => a.loadItemCount);
    final int length = context.select<ArtifactNotifier, int>(
        (ArtifactNotifier a) => a.combinations.length);
    if (index >= length) {
      return const SizedBox(
        height: 0.0,
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      child: ElevatedButton(
        onPressed: context.read<ArtifactNotifier>().loadMoreItem,
        child: Container(
          width: Size.infinite.width,
          alignment: Alignment.center,
          child: const Text('더 보기'),
        ),
      ),
    );
  }
}

class _CombinationCard extends StatelessWidget {
  final Map data;

  const _CombinationCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final Map colors = {
      '불': Colors.red,
      '바': Colors.blue,
      '땅': Colors.orange,
      '풀': Colors.green,
      '오': Theme.of(context).textTheme.bodyMedium!.color,
      '-': Theme.of(context).textTheme.bodyMedium!.color,
    };
    return Card(
      margin: const EdgeInsets.all(12.0),
      shadowColor:
          data['name'].toString().startsWith('[') ? Colors.red : Colors.green,
      elevation: 8.0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ListTile(
              title: TitleText(
                data['name'],
                bold: true,
              ),
            ),
            const Divider(),
            const Row(
              children: [
                Expanded(
                  child: Text('조합 효과',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Text('광명석',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Text('조합 + 광명석 효과',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: data['effect']
                        .map<Widget>((e) => Text(
                              e['full_name'],
                              textAlign: TextAlign.center,
                            ))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: data['formula']
                        .map<Widget>((e) => Text(
                              e,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colors[e[0]]),
                            ))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: context
                        .read<ArtifactNotifier>()
                        .getEffects(data['name'])
                        .map<Widget>((e) => Text(
                              e,
                              textAlign: TextAlign.center,
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardList extends StatelessWidget {
  const _CardList({super.key});

  @override
  Widget build(BuildContext context) {
    final ArtifactNotifier notifier = context.watch<ArtifactNotifier>();
    int count = notifier.loadItemCount > notifier.combinations.length
        ? notifier.combinations.length
        : notifier.loadItemCount;
    if (notifier.combinations.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 120.0,
          alignment: Alignment.center,
          child: const Text('검색 결과가 없습니다.'),
        ),
      );
    }
    return SliverList(
        delegate: SliverChildListDelegate(
      notifier.combinations
          .sublist(0, count)
          .map((e) => _CombinationCard(data: e))
          .toList(),
    ));
  }
}

class _KeywordChips extends StatelessWidget {
  const _KeywordChips({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> keywords =
        context.select<ArtifactNotifier, List<String>>(
            (ArtifactNotifier a) => a.keywords);
    return Container(
      margin: const EdgeInsets.all(12.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        children: keywords
            .map((e) => Chip(
                  label: Text(e),
                  onDeleted: () =>
                      context.read<ArtifactNotifier>().removeKeyword(e),
                ))
            .toList(),
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({super.key});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final ArtifactNotifier notifier = context.read<ArtifactNotifier>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<String>(
          fieldViewBuilder: (context, controller, focusNode, onSubmit) {
            textEditingController = controller;
            focusNode = focusNode;
            return TextField(
              controller: controller,
              focusNode: focusNode,
              maxLength: 20,
              onSubmitted: (String value) {
                if (notifier.autoComplete(value.trim()).isNotEmpty &&
                    notifier.autoComplete(value.trim()).first == value) {
                  notifier.addKeyword(value.trim());
                  textEditingController.clear();
                } else {
                  onSubmit();
                }
                FocusScope.of(context).requestFocus(focusNode);
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffix: ElevatedButton(
                  child: const Text('추가'),
                  onPressed: () {
                    if (textEditingController.text.trim().isNotEmpty) {
                      notifier.addKeyword(textEditingController.text.trim());
                    }
                    textEditingController.clear();
                    //FocusManager.instance.primaryFocus?.unfocus();
                    FocusScope.of(context).requestFocus(focusNode);
                  },
                ),
                hintText: 'ex) 천적, 몬스터 추가 공격력, 항해',
                labelText: '검색',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            );
          },
          optionsViewBuilder: (BuildContext context,
              AutocompleteOnSelected<String> onSelected,
              Iterable<String> options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 500,
                    maxWidth: constraints.biggest.width,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return InkWell(
                        onTap: () {
                          onSelected(option);
                        },
                        child: Builder(builder: (BuildContext context) {
                          final bool highlight =
                              AutocompleteHighlightedOption.of(context) ==
                                  index;
                          if (highlight) {
                            SchedulerBinding.instance
                                .addPostFrameCallback((Duration timeStamp) {
                              Scrollable.ensureVisible(context, alignment: 0.5);
                            });
                          }
                          return Container(
                            color:
                                highlight ? Theme.of(context).focusColor : null,
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              RawAutocomplete.defaultStringForOption(option),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.trim().isEmpty) {
              return const Iterable<String>.empty();
            }
            return notifier.autoComplete(textEditingValue.text.trim());
          },
        );
      },
    );
  }
}
