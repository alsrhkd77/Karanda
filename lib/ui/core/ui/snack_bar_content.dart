import 'package:flutter/material.dart';
import 'package:karanda/model/app_notification_message.dart';
import 'package:karanda/ui/core/theme/features_icon.dart';
import 'package:karanda/utils/extension/go_router_extension.dart';

class SnackBarContent extends StatelessWidget {
  final AppNotificationMessage data;
  final TextStyle? textStyle;

  const SnackBarContent({
    super.key,
    required this.data,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).snackBarTheme.contentTextStyle?.color ??
        Theme.of(context).colorScheme.onInverseSurface;
    /*return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              FeaturesIcon.byFeature(data.feature),
              color: color
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: data.mdContents
                ? _Markdown(text: data.content, textStyle: textStyle,)
                : Text(data.content, style: textStyle),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: data.route != null
                ? ElevatedButton(
              onPressed: () => context.goWithGa(data.route!),
              child: const Text("Go"),
            )
                : const SizedBox(),
          ),
        ],
      ),
    );*/
    return ListTile(
      leading: Icon(
        FeaturesIcon.byFeature(data.feature),
        size: textStyle?.fontSize,
        color: color,
      ),
      title: Center(
        child: data.mdContents
            ? _Markdown(text: data.content, textStyle: textStyle,)
            : Text(data.content, style: textStyle),
      ),
      trailing: data.route != null
          ? ElevatedButton(
              onPressed: () => context.goWithGa(data.route!),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Go"),
              ),
            )
          : null,
      textColor: color,
    );
  }
}

class _Markdown extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;

  const _Markdown({super.key, required this.text, this.textStyle});

  @override
  Widget build(BuildContext context) {
    final parsed = text.split("**");
    return Text.rich(
      TextSpan(
        children: List.generate(parsed.length, (index) {
          return index % 2 == 1
              ? TextSpan(
                  text: parsed[index],
                  style: const TextStyle(fontWeight: FontWeight.bold))
              : TextSpan(text: parsed[index]);
        }),
      ),
      style: textStyle,
    );
  }
}
