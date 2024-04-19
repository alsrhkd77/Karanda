import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/common/launch_url.dart';
import 'package:karanda/common/release_api_provider.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:markdown/markdown.dart' as md;

class ChangeLogPage extends StatefulWidget {
  const ChangeLogPage({super.key});

  @override
  State<ChangeLogPage> createState() => _ChangeLogPageState();
}

class _ChangeLogPageState extends State<ChangeLogPage> {
  String markdown = '';

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    List data = await ReleaseApiProvider.getReleases();
    String result = "Karanda 패치 내역 \n ============= \n";
    for (Map item in data) {
      bool prerelease = item["prerelease"] ?? true;
      if (!prerelease) {
        String name = item["name"] ?? '';
        String body = item["body"] ?? '';
        result = '$result\n***\n# $name\n$body';
      }
    }
    setState(() {
      markdown = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = GlobalProperties.scrollViewHorizontalPadding(
        MediaQuery.of(context).size.width);
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: markdown.isEmpty
          ? const LoadingIndicator()
          : Markdown(
              data: markdown,
              extensionSet: md.ExtensionSet(
                md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                <md.InlineSyntax>[
                  md.EmojiSyntax(),
                  ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
                ],
              ),
              styleSheet: MarkdownStyleSheet(
                  blockquoteDecoration:
                      BoxDecoration(color: Colors.grey.withOpacity(0.1)),
                  codeblockDecoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  code: TextStyle(
                      backgroundColor: Colors.grey.shade400,
                      color: Colors.black)),
              padding: EdgeInsets.symmetric(
                  vertical: 12.0, horizontal: horizontalPadding + 6.0),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            launchURL('https://github.com/HwanSangYeonHwa/Karanda/releases'),
        child: const Icon(Icons.open_in_new),
      ),
    );
  }
}
