import '../artifact/artifact_controller.dart';
import '../widgets/default_app_bar.dart';
import '../widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ArtifactPage extends StatefulWidget {
  const ArtifactPage({Key? key}) : super(key: key);

  @override
  State<ArtifactPage> createState() => _ArtifactPageState();
}

class _ArtifactPageState extends State<ArtifactPage> {
  final ArtifactController _artifactController = ArtifactController();
  TextEditingController _textEditingController = TextEditingController();
  final ScrollController _mainScrollController = ScrollController();

  Widget buildCardList() {
    if (_artifactController.combinations.isEmpty) {
      return Container(
        height: 120.0,
        alignment: Alignment.center,
        child: const Text('검색 결과가 없습니다.'),
      );
    }
    return ListView.builder(
        shrinkWrap: true,
        itemCount: _artifactController.loadItemCount.value >
                _artifactController.combinations.length
            ? _artifactController.combinations.length
            : _artifactController.loadItemCount.value,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return combinationCard(_artifactController.combinations[index]);
        });
  }

  Widget combinationCard(Map data) {
    var _colors = {
      '불': Colors.red,
      '바': Colors.blue,
      '땅': Colors.orange,
      '풀': Colors.green,
      '오': context.textTheme.bodyMedium!.color,
      '-': context.textTheme.bodyMedium!.color,
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
            Row(
              children: const [
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
                        .map<Widget>((e) =>
                            Text(e['full_name'], textAlign: TextAlign.center))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: data['formula']
                        .map<Widget>((e) => Text(
                              e,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: _colors[e[0]]),
                            ))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: _artifactController
                        .getEffects(data['name'])
                        .map<Widget>(
                            (e) => Text(e, textAlign: TextAlign.center))
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

  Widget buildChip() {
    return Container(
      margin: const EdgeInsets.all(12.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        children: _artifactController.keywords
            .map((e) => Chip(
                  label: Text(
                    e,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onDeleted: () => _artifactController.removeKeyword(e),
                  backgroundColor: Colors.blue,
                  deleteIconColor: Colors.white,
                ))
            .toList(),
      ),
    );
  }

  Widget buildSearchTextBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<String>(
          fieldViewBuilder: (context, controller, focusNode, onSubmit) {
            _textEditingController = controller;
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              maxLength: 20,
              onFieldSubmitted: (String value) {
                if (value.trim().isNotEmpty) {
                  _artifactController.addKeyword(value);
                }
                controller.clear();
                focusNode.requestFocus();
              },
              decoration: InputDecoration(
                suffixIcon: const Icon(FontAwesomeIcons.searchengin),
                hintText: 'ex) 천적, 몬스터 추가 공격력, 항해',
                labelText: '검색',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            );
          },
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.trim().isEmpty) {
              return const Iterable<String>.empty();
            }
            return _artifactController
                .autoComplete(textEditingValue.text.trim());
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(4.0)),
                ),
                child: Container(
                  height: 52.0 * options.length,
                  width: constraints.biggest.width,
                  constraints: BoxConstraints(maxHeight: Get.height / 2),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    shrinkWrap: false,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(option),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildLoadButton() {
    if (_artifactController.combinations.length ==
        _artifactController.loadItemCount.value) {
      return const SizedBox(
        height: 0.0,
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      child: ElevatedButton(
        child: Container(
          width: Size.infinite.width,
          alignment: Alignment.center,
          child: const Text('더 보기'),
        ),
        onPressed: _artifactController.loadMoreItem,
      ),
    );
  }

  Widget buildFilterButton(){
    return OutlinedButton(
      child: Text(_artifactController.orFilter.value
          ? 'Or 연산'
          : 'And 연산'),
      onPressed: _artifactController.changeFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: FutureBuilder(
        future: _artifactController.getData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: SpinKitFadingCube(
                size: 120.0,
                color: Colors.blue,
              ),
            );
          } else {
            return SingleChildScrollView(
              controller: _mainScrollController,
              child: Container(
                margin: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(FontAwesomeIcons.splotch),
                      title: const TitleText(
                        '광명석 조합식',
                        bold: true,
                      ),
                      trailing: Obx(buildFilterButton),
                    ),
                    Container(
                      constraints: const BoxConstraints(
                        maxWidth: 900,
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: buildSearchTextBar(),
                            trailing: ElevatedButton(
                              child: const Text('추가'),
                              onPressed: () {
                                if (_textEditingController.text
                                    .trim()
                                    .isNotEmpty) {
                                  _artifactController.addKeyword(
                                      _textEditingController.text.trim());
                                }
                                _textEditingController.clear();
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                            ),
                          ),
                          Obx(buildChip),
                          Obx(buildCardList),
                          Obx(buildLoadButton)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
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
    );
  }
}
