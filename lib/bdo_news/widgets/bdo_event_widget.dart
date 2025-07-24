import 'dart:async';

import 'package:flutter/material.dart';
import 'package:karanda/bdo_news/bdo_news_data_controller.dart';
import 'package:karanda/bdo_news/models/bdo_event_model.dart';
import 'package:karanda/bdo_news/widgets/deadline_tag_chip.dart';
import 'package:karanda/bdo_news/widgets/new_tag_chip.dart';
import 'package:karanda/common/custom_scroll_behavior.dart';
import 'package:karanda/common/go_router_extension.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class BdoEventWidget extends StatefulWidget {
  const BdoEventWidget({super.key});

  @override
  State<BdoEventWidget> createState() => _BdoEventWidgetState();
}

class _BdoEventWidgetState extends State<BdoEventWidget> {
  final BdoNewsDataController dataController = BdoNewsDataController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => dataController.subscribeEvents());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: StreamBuilder(
        stream: dataController.nearDeadlineEvents,
        builder: (context, nearDeadlineEvents) {
          return StreamBuilder(
            stream: dataController.newEvents,
            builder: (context, newEvents) {
              if (!nearDeadlineEvents.hasData || !newEvents.hasData) {
                return const LoadingIndicator();
              }
              if (nearDeadlineEvents.requireData.isNotEmpty) {
                return _Contents(
                    events: nearDeadlineEvents.requireData, nearDeadline: true);
              }
              return _Contents(
                  events: newEvents.requireData, nearDeadline: false);
            },
          );
        },
      ),
    );
  }
}

class _Contents extends StatefulWidget {
  final bool nearDeadline;
  final List<BdoEventModel> events;

  const _Contents({
    super.key,
    required this.events,
    required this.nearDeadline,
  });

  @override
  State<_Contents> createState() => _ContentsState();
}

class _ContentsState extends State<_Contents> {
  final PageController pageController = PageController(initialPage: 0);
  int nextPage = 1;
  Timer? animationTimer;

  @override
  void initState() {
    super.initState();
    if(widget.events.length > 1){
      animationTimer = Timer(const Duration(seconds: 5), scrollPage,);
    }
  }

  @override
  void activate() {
    super.activate();
    if(widget.events.length > 1){
      animationTimer = Timer(const Duration(seconds: 5), scrollPage,);
    }
  }

  @override
  void deactivate() {
    animationTimer?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    animationTimer?.cancel();
    super.dispose();
  }

  void scrollPage() {
    pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 250),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.goWithGa('/event-calendar'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
            leading: const Icon(Icons.celebration_outlined),
            title: TitleText(widget.nearDeadline ? '마감 임박 이벤트' : '신규 이벤트'),
          ),
          AspectRatio(
            aspectRatio: 1.8,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              clipBehavior: Clip.antiAlias,
              child: PageView.builder(
                controller: pageController,
                itemCount: widget.events.length,
                scrollBehavior: CustomScrollBehavior(),
                onPageChanged: (index) {
                  int next = index + 1;
                  if (next >= widget.events.length) {
                    next = 0;
                  }
                  setState(() {
                    nextPage = next;
                  });
                  animationTimer?.cancel();
                  animationTimer = Timer(
                    const Duration(seconds: 5),
                    scrollPage,
                  );
                },
                itemBuilder: (context, index) =>
                    _CardContent(event: widget.events[index]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SmoothPageIndicator(
              controller: pageController,
              count: widget.events.length,
              effect: const WormEffect(
                dotWidth: 8,
                dotHeight: 8,
                activeDotColor: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final BdoEventModel event;

  const _CardContent({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(event.url)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            event.thumbnail,
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
                event.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 8,
            child: event.nearDeadline
                ? DeadlineTagChip(
                    count: event.countToInt(),
                  )
                : (event.newTag ? const NewTagChip() : Container()),
          ),
        ],
      ),
    );
  }
}
