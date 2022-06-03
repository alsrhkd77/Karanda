import 'package:black_tools/artifact/artifact_controller.dart';
import 'package:black_tools/widgets/default_app_bar.dart';
import 'package:black_tools/widgets/title_text.dart';
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

  Widget buildCardList() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: 15,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return combinationCard();
        });
  }

  Widget combinationCard() {
    return Card(
      margin: EdgeInsets.all(12.0),
      shadowColor: Colors.green,
      elevation: 12.0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text('효과이름'),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('지식 획득 시 높은 등급 지식 획득 확률 증가 +5%\n효과2\n효과3',
                          textAlign: TextAlign.center)
                    ],
                  ),
                ),
                VerticalDivider(),
                Expanded(
                  child: Text('바람의 광명석 : 발돋움(기술)\n광명석2\n광명석3',
                      textAlign: TextAlign.center),
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
      margin: EdgeInsets.all(12.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        children: _artifactController.keywords
            .map((e) => Chip(
                  label: Text(e),
                  onDeleted: () => _artifactController.removeKeyword(e),
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
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
              child: Container(
                margin: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(FontAwesomeIcons.cookie),
                      title: TitleText(
                        '광명석 조합식',
                        bold: true,
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(
                        maxWidth: 900,
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: LayoutBuilder(
                              builder: (context, constraints) {
                                return Autocomplete<String>(
                                  fieldViewBuilder: (context, controller,
                                      focusNode, onSubmit) {
                                    _textEditingController = controller;
                                    return TextFormField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      maxLength: 20,
                                    );
                                  },
                                  optionsBuilder:
                                      (TextEditingValue textEditingValue) {
                                    if (textEditingValue.text.isEmpty) {
                                      return const Iterable<String>.empty();
                                    }
                                    return _artifactController
                                        .autoComplete(textEditingValue.text);
                                  },
                                  optionsViewBuilder:
                                      (context, onSelected, options) {
                                    return Align(
                                      alignment: Alignment.topLeft,
                                      child: Material(
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              bottom: Radius.circular(4.0)),
                                        ),
                                        child: SizedBox(
                                          height: 52.0 * options.length,
                                          width: constraints.biggest.width,
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount: options.length,
                                            shrinkWrap: false,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final String option =
                                                  options.elementAt(index);
                                              return InkWell(
                                                onTap: () => onSelected(option),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
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
                            ),
                            trailing: ElevatedButton(
                              child: const Text('추가'),
                              onPressed: () {
                                _artifactController
                                    .addKeyword(_textEditingController.text);
                                _textEditingController.clear();
                              },
                            ),
                          ),
                          Obx(buildChip),
                          buildCardList(),
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
    );
  }
}
