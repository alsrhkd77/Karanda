import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:karanda/enums/bdo_news_category.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/bdo_news.dart';
import 'package:karanda/ui/core/theme/app_colors.dart';
import 'package:karanda/utils/launch_url.dart';

/// 뉴스 리스트 행(row) 레이아웃 구간
enum NewsListLayout {
  narrow, // < 600
  medium, // 600 ~ 900
  wide; // > 900

  static NewsListLayout byWidth(double width) {
    if (width < 600) return narrow;
    if (width <= 900) return medium;
    return wide;
  }

  /// 16:9 썸네일 너비 (높이는 ×9/16)
  double get thumbnailWidth {
    return switch (this) {
      narrow => 96.0,
      medium => 112.0,
      wide => 128.0,
    };
  }
}

class NewsListItem extends StatelessWidget {
  final BdoNews news;
  final BDORegion appRegion;
  final NewsListLayout layout;

  const NewsListItem({
    super.key,
    required this.news,
    required this.appRegion,
    required this.layout,
  });

  bool get _isWide => layout == NewsListLayout.wide;

  /// 종료된 이벤트 (마감일이 오늘이거나 지남)
  bool get _closed {
    final days = news.daysUntilDeadline;
    return news.category == BdoNewsCategory.event && days != null && days <= 0;
  }

  @override
  Widget build(BuildContext context) {
    final gap = _isWide ? 14.0 : 12.0;
    return InkWell(
      onTap: () => launchURL(news.resolveUrl(appRegion)),
      child: Opacity(
        // 종료된 이벤트는 흐리게 처리해 진행 중 항목과 구분
        opacity: _closed ? 0.5 : 1.0,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 4.0,
            vertical: layout == NewsListLayout.narrow ? 10.0 : 11.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Thumbnail(news: news, layout: layout),
              SizedBox(width: gap),
              Expanded(child: _Content(news: news, layout: layout)),
              if (_isWide) ...[
                SizedBox(width: gap),
                _WideTrailing(news: news),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final BdoNews news;
  final NewsListLayout layout;

  const _Thumbnail({required this.news, required this.layout});

  @override
  Widget build(BuildContext context) {
    final width = layout.thumbnailWidth;
    final height = width * 9 / 16;
    final categoryColor = AppColors.bdoNewsCategoryColor(news.category);
    final placeholder = Container(
      width: width,
      height: height,
      color: categoryColor.withValues(alpha: 0.15),
      child: Icon(_categoryIcon(news.category), color: categoryColor),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        child: news.thumbnail == null
            ? placeholder
            : Image.network(
                news.thumbnail!,
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final BdoNews news;
  final NewsListLayout layout;

  const _Content({required this.news, required this.layout});

  bool get _isWide => layout == NewsListLayout.wide;

  @override
  Widget build(BuildContext context) {
    final badge = _newsBadge(context, news);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _CategoryLabel(category: news.category),
            // 좁은·중간 화면은 배지(주요/D-N)를 카테고리 오른쪽 메타 줄에 둔다.
            if (!_isWide && badge != null) ...[
              const SizedBox(width: 6.0),
              badge,
            ],
          ],
        ),
        const SizedBox(height: 4.0),
        Text(
          news.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: (layout == NewsListLayout.narrow
                  ? TextTheme.of(context).bodyMedium
                  : TextTheme.of(context).bodyLarge)
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
        // 좁은·중간 화면은 날짜/기간을 제목 아래에 둔다 (넓은 화면은 오른쪽 열).
        if (!_isWide) ...[
          const SizedBox(height: 4.0),
          Text(
            _metaDateText(context, news),
            style: TextTheme.of(context).bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }
}

/// 넓은 화면 오른쪽 열 — 배지(주요/D-N) 아래에 날짜/기간
class _WideTrailing extends StatelessWidget {
  final BdoNews news;

  const _WideTrailing({required this.news});

  @override
  Widget build(BuildContext context) {
    final badge = _newsBadge(context, news);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (badge != null) ...[
          badge,
          const SizedBox(height: 6.0),
        ],
        Text(
          _metaDateText(context, news),
          style: TextTheme.of(context).bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

/// 작은 색상 점 + 카테고리명
class _CategoryLabel extends StatelessWidget {
  final BdoNewsCategory category;

  const _CategoryLabel({required this.category});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7.0,
          height: 7.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.bdoNewsCategoryColor(category),
          ),
        ),
        const SizedBox(width: 5.0),
        Text(
          context.tr("news.${category.name}"),
          style: TextTheme.of(context).bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

/// 썸네일이 없을 때 카테고리별 placeholder 아이콘
IconData _categoryIcon(BdoNewsCategory category) {
  return switch (category) {
    BdoNewsCategory.notice => Icons.campaign_outlined,
    BdoNewsCategory.update => Icons.new_releases_outlined,
    BdoNewsCategory.event => Icons.celebration_outlined,
    BdoNewsCategory.lab => Icons.science_outlined,
  };
}

/// 항목별 강조 배지: 주요(UPDATE/LAB) 또는 이벤트 D-N/종료 칩. 없으면 null.
Widget? _newsBadge(BuildContext context, BdoNews news) {
  final isMajorCategory = news.category == BdoNewsCategory.update ||
      news.category == BdoNewsCategory.lab;
  if (news.isMajor && isMajorCategory) {
    return _Pill(
      text: context.tr("news.major"),
      color: AppColors.bdoNewsCategoryColor(news.category),
    );
  }
  if (news.category == BdoNewsCategory.event && news.deadline != null) {
    final days = news.daysUntilDeadline!;
    if (days <= 0) {
      return _Pill(text: context.tr("news.closed"), outline: true);
    }
    return _Pill(
      text: "D-$days",
      // 마감 임박(3일 이내)은 강조색(error), 그 외는 기본 강조색(primary)
      color: days <= 3
          ? Theme.of(context).colorScheme.error
          : Theme.of(context).colorScheme.primary,
      bold: true,
    );
  }
  return null;
}

/// 리스트 하단(또는 오른쪽 열)에 표시할 날짜/기간 텍스트.
/// 이벤트: 마감일 "yyyy.MM.dd 까지", 상시(null)면 "상시". 그 외: 게시일.
String _metaDateText(BuildContext context, BdoNews news) {
  final format = DateFormat('yyyy.MM.dd');
  if (news.category == BdoNewsCategory.event) {
    if (news.deadline == null) return context.tr("news.ongoing");
    return context.tr("news.until", args: [format.format(news.deadline!)]);
  }
  return format.format(news.publishedAt);
}

/// 작은 톤 배지(pill). [outline]이면 외곽선 스타일(종료용).
class _Pill extends StatelessWidget {
  final String text;
  final Color? color;
  final bool bold;
  final bool outline;

  const _Pill({
    required this.text,
    this.color,
    this.bold = false,
    this.outline = false,
  });

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
      decoration: outline
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 0.5,
              ),
            )
          : BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: color!.withValues(alpha: 0.15),
            ),
      child: Text(
        text,
        style: TextTheme.of(context).labelSmall?.copyWith(
              color: outline ? onSurfaceVariant : color,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
            ),
      ),
    );
  }
}
