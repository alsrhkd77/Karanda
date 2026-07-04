import 'dart:async';

import 'package:flutter/material.dart';
import 'package:karanda/enums/bdo_news_category.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/bdo_news.dart';
import 'package:karanda/repository/app_settings_repository.dart';
import 'package:karanda/repository/bdo_news_repository.dart';

/// 뉴스 페이지 목록·필터·정렬 상태.
class NewsController extends ChangeNotifier {
  final BdoNewsRepository _bdoNewsRepository;
  final AppSettingsRepository _appSettingsRepository;
  late final StreamSubscription _news;
  late final StreamSubscription _region;

  List<BdoNews>? _newsList;
  bool failed = false;

  /// 선택된 카테고리 필터 (null = 전체)
  BdoNewsCategory? filter;

  /// 오래된순 정렬 여부 (기본: 최신순)
  bool ascending = false;

  /// 이벤트 필터 전용 — 진행 중만 보기
  bool ongoingOnly = false;

  NewsController({
    required BdoNewsRepository bdoNewsRepository,
    required AppSettingsRepository appSettingsRepository,
  })  : _bdoNewsRepository = bdoNewsRepository,
        _appSettingsRepository = appSettingsRepository {
    _news = _bdoNewsRepository.newsStream.listen(_onNewsUpdate);
    _region = _appSettingsRepository.settingsStream
        .map((value) => value.region)
        .distinct()
        .listen((_) => loadNews());
  }

  bool get loading => _newsList == null && !failed;

  BDORegion get appRegion => _appSettingsRepository.region ?? BDORegion.KR;

  /// 필터·정렬이 적용된 표시용 목록
  List<BdoNews> get newsList {
    var result = List<BdoNews>.from(_newsList ?? []);
    if (filter == BdoNewsCategory.event && ongoingOnly) {
      result = result.where((news) => news.inProgress).toList();
      // 진행 중(마감 존재)은 마감 임박 순, 상시는 그 뒤에 최신순
      result.sort((a, b) {
        if (a.deadline == null && b.deadline == null) {
          return b.publishedAt.compareTo(a.publishedAt);
        }
        if (a.deadline == null) return 1;
        if (b.deadline == null) return -1;
        return a.deadline!.compareTo(b.deadline!);
      });
    } else if (ascending) {
      // 서버 정렬(최신순)의 역순 — 전체 목록을 이미 가지고 있으므로 로컬 처리
      result = result.reversed.toList();
    }
    return result;
  }

  Future<void> loadNews() async {
    try {
      failed = false;
      _newsList = null;
      notifyListeners();
      // 연구소 필터는 리전 무관 LAB 전용 조회
      if (filter == BdoNewsCategory.lab) {
        await _bdoNewsRepository.loadNews(region: BDORegion.LAB);
      } else {
        await _bdoNewsRepository.loadNews(region: appRegion, category: filter);
      }
    } catch (_) {
      failed = true;
      notifyListeners();
    }
  }

  void setFilter(BdoNewsCategory? value) {
    if (filter == value) return;
    filter = value;
    loadNews();
  }

  void setAscending(bool value) {
    if (ascending == value) return;
    ascending = value;
    notifyListeners();
  }

  void setOngoingOnly(bool value) {
    if (ongoingOnly == value) return;
    ongoingOnly = value;
    notifyListeners();
  }

  void _onNewsUpdate(List<BdoNews> value) {
    _newsList = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _news.cancel();
    _region.cancel();
    super.dispose();
  }
}
