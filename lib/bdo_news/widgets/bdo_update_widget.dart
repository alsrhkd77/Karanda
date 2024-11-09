import 'package:flutter/material.dart';
import 'package:karanda/bdo_news/bdo_news_data_controller.dart';
import 'package:karanda/bdo_news/models/bdo_update_model.dart';
import 'package:karanda/bdo_news/widgets/new_tag_chip.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:url_launcher/url_launcher.dart';

class BdoUpdateWidget extends StatefulWidget {
  const BdoUpdateWidget({super.key});

  @override
  State<BdoUpdateWidget> createState() => _BdoUpdateWidgetState();
}

class _BdoUpdateWidgetState extends State<BdoUpdateWidget> {
  final BdoNewsDataController dataController = BdoNewsDataController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      dataController.subscribeLabUpdates();
      dataController.subscribeUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: StreamBuilder(
        stream: dataController.labUpdates,
        builder: (context, labUpdates) {
          return StreamBuilder(
            stream: dataController.updates,
            builder: (context, updates) {
              if (!labUpdates.hasData || !updates.hasData) {
                return const LoadingIndicator();
              }
              if (labUpdates.requireData.first.isRecent()) {
                return _Contents(
                  title: '연구소',
                  icon: Icons.science_outlined,
                  item: labUpdates.requireData.first,
                );
              }
              return _Contents(
                title: '업데이트',
                icon: Icons.update,
                item:
                    updates.requireData.firstWhere((element) => element.major),
              );
            },
          );
        },
      ),
    );
  }
}

class _Contents extends StatelessWidget {
  final String title;
  final IconData icon;
  final BdoUpdateModel item;

  const _Contents({
    super.key,
    required this.title,
    required this.item,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(item.url)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
            leading: Icon(icon),
            title: TitleText(title),
          ),
          AspectRatio(
            aspectRatio: 1.8,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.thumbnail,
                    fit: BoxFit.fill,
                  ),
                  Positioned(
                    left: -1,
                    bottom: -1,
                    child: Container(
                      width: 800,
                      height: 80,
                      alignment: Alignment.bottomLeft,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                            Colors.black
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const Positioned(
                    right: 10,
                    top: 8,
                    child: NewTagChip(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 24.0,
          )
        ],
      ),
    );
  }
}
