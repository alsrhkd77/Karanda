import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/enums/bdo_news_category.dart';
import 'package:karanda/ui/news/controller/news_controller.dart';
import 'package:provider/provider.dart';

/// 카테고리 필터 + 정렬 + (이벤트 선택 시) 진행 중만 보기
class NewsFilterBar extends StatelessWidget {
  const NewsFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NewsController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              _FilterChip(
                label: context.tr("news.all"),
                selected: controller.filter == null,
                onSelected: () => controller.setFilter(null),
              ),
              ...BdoNewsCategory.values.map((category) {
                return _FilterChip(
                  label: context.tr("news.${category.name}"),
                  selected: controller.filter == category,
                  onSelected: () => controller.setFilter(category),
                );
              }),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text(context.tr("news.sortLatest")),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(context.tr("news.sortOldest")),
                  ),
                ],
                selected: {controller.ascending},
                onSelectionChanged: (value) =>
                    controller.setAscending(value.first),
                showSelectedIcon: false,
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const Spacer(),
              if (controller.filter == BdoNewsCategory.event) ...[
                Text(
                  context.tr("news.ongoingOnly"),
                  style: TextTheme.of(context).bodyMedium,
                ),
                Switch(
                  value: controller.ongoingOnly,
                  onChanged: controller.setOngoingOnly,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final void Function() onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
