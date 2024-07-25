import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:karanda/common/go_router_extension.dart';
import 'package:karanda/trade_market/market_item_model.dart';
import 'package:karanda/trade_market/trade_market_notifier.dart';
import 'package:provider/provider.dart';

class TradeMarketSearchBarWidget extends StatefulWidget {
  const TradeMarketSearchBarWidget({super.key});

  @override
  State<TradeMarketSearchBarWidget> createState() =>
      _TradeMarketSearchBarWidgetState();
}

class _TradeMarketSearchBarWidgetState
    extends State<TradeMarketSearchBarWidget> {
  TextEditingController textEditingController = TextEditingController();
  Iterable<String> lastOptions = [];
  late final _Debounceable<Iterable<String>?, String> debouncedSearch;
  //FocusNode focusNode = FocusNode();  // Use to request focus

  void goDetail(String code, String name) {
    textEditingController.text = "";
    context.goWithGa('/trade-market/detail?name=$name', extra: code);
  }

  Future<Iterable<String>> search(String value) async {
    //Search
    if (value.trim().isEmpty) {
      return lastOptions = const Iterable<String>.empty();
    }
    return context
        .read<TradeMarketNotifier>()
        .itemNames
        .keys
        .where((element) => element.contains(value));
  }

  @override
  void initState() {
    super.initState();
    debouncedSearch = _debounce<Iterable<String>?, String>(search);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TradeMarketNotifier>(builder: (context, notifier, _) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Autocomplete<String>(
            fieldViewBuilder: (context, controller, focusNode, onSubmit) {
              textEditingController = controller;
              //focusNode = focusNode;
              return TextField(
                controller: controller,
                focusNode: focusNode,
                maxLength: 20,
                textInputAction: TextInputAction.go,
                onSubmitted: (String value) {
                  final result = notifier.itemNames.keys
                      .where((element) => element.contains(value.trim()));
                  if (result.isNotEmpty && result.first == value.trim()) {
                    goDetail(notifier.itemNames[result.first]!, result.first);
                  } else {
                    onSubmit();
                  }
                  //FocusScope.of(context).requestFocus(focusNode);
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  counter: Container(),
                  hintText: '검색어를 입력해주세요',
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
                        MarketItemModel? item = notifier.itemInfo[notifier.itemNames[option]];
                        if(item == null){
                          return Container();
                        }
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
                                Scrollable.ensureVisible(context,
                                    alignment: 0.5);
                              });
                            }
                            return Container(
                              color: highlight
                                  ? Theme.of(context).focusColor
                                  : null,
                              padding: const EdgeInsets.all(16.0),
                              child: ListTile(
                                /*
                                leading: BdoItemImageWidget(
                                  code: item.code,
                                  enhancementLevel: '',
                                  size: 50,
                                  grade: item.grade,
                                ),
                                 */
                                title: Text(option),
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
            optionsBuilder: (TextEditingValue textEditingValue) async {
              String input = textEditingValue.text.replaceAll(' ', '');
              if(input.isEmpty){
                return const Iterable<String>.empty();
              }
              return context
                  .read<TradeMarketNotifier>()
                  .itemNames
                  .keys
                  .where((element) => element.replaceAll(' ', '').contains(input));
              /*
              final Iterable<String>? options =
                  await debouncedSearch(textEditingValue.text);
              if (options == null) {
                return lastOptions;
              }
              lastOptions = options;
              return options;
              */
            },
            onSelected: (String value) {
              setState(() {
                textEditingController.text = value;
              });
              goDetail(notifier.itemNames[value]!, value);
            },
          );
        },
      );
    });
  }
}

typedef _Debounceable<S, T> = FutureOr<S?> Function(T parameter);

/// Returns a new function that is a debounced version of the given function.
///
/// This means that the original function will be called only after no calls
/// have been made for the given Duration.
_Debounceable<S, T> _debounce<S, T>(_Debounceable<S?, T> function) {
  _DebounceTimer? debounceTimer;

  return (T parameter) async {
    if (debounceTimer != null && !debounceTimer!.isCompleted) {
      debounceTimer!.cancel();
    }
    debounceTimer = _DebounceTimer();
    try {
      await debounceTimer!.future;
    } catch (error) {
      if (error is _CancelException) {
        return null;
      }
      rethrow;
    }
    return function(parameter);
  };
}

// A wrapper around Timer used for debouncing.
class _DebounceTimer {
  Duration debounceDuration = const Duration(milliseconds: 650);

  _DebounceTimer() {
    _timer = Timer(debounceDuration, _onComplete);
  }

  late final Timer _timer;
  final Completer<void> _completer = Completer<void>();

  void _onComplete() {
    _completer.complete();
  }

  Future<void> get future => _completer.future;

  bool get isCompleted => _completer.isCompleted;

  void cancel() {
    _timer.cancel();
    _completer.completeError(const _CancelException());
  }
}

// An exception indicating that the timer was canceled.
class _CancelException implements Exception {
  const _CancelException();
}
