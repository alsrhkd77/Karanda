import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'dart:developer' as developer;

class YolunakeaMoonPage extends StatefulWidget {
  const YolunakeaMoonPage({Key? key}) : super(key: key);

  @override
  State<YolunakeaMoonPage> createState() => _YolunakeaMoonPageState();
}

class _YolunakeaMoonPageState extends State<YolunakeaMoonPage> {
  final List<int> containerSize = [3, 4, 6, 7, 5];
  List<int> container = [0, 0, 0, 0, 0];
  List<int> target = [0, 0, 0, 0, 0];
  List<List<int>> result = [];

  int count = 0;

  Future<void> checkAndStart() async {
    bool check = true;
    int _container = 0;
    int _target = 0;
    for (int i = 0; i < containerSize.length; i++) {
      _container += container[i];
      _target += target[i];
      if (container[i] > containerSize[i] || target[i] > containerSize[i]) {
        check = false;
        break;
      }
    }
    if (_container == 0 || _target == 0) {
      check = false;
    }
    if (_container < _target || listEquals(container, target)) {
      check = false;
    }
    if (check) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: const Text('연산 진행중'),
                content: SizedBox(
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SpinKitSpinningLines(
                        size: 80.0,
                        color: Colors.blue,
                      ),
                      Text('$count가지 경우의 수를 탐색중입니다')
                    ],
                  ),
                ),
              );
            });
          });
      calculate();
      await Future.delayed(const Duration(seconds: 1));
      Navigator.of(context).pop();
    } else {
      Get.dialog(
        AlertDialog(
          title: const Text('진행 불가'),
          content: const Text('입력값을 확인해주세요'),
          actions: [
            OutlinedButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text('확인'))
          ],
        ),
      );
    }
  }

  void calculate() {
    List<List<int>> _unsolved = [];
    List<List<int>> unsolved = [];
    List<int> solved = [];
    Map<String, List<int>> node = {};
    setState(() {
      result.clear();
    });

    unsolved.add(container);
    // start
    while (true) {
      _unsolved = List.from(unsolved);
      if (_unsolved.isEmpty && solved.isEmpty) {
        setState(() {
          count = -1;
        });
        developer.log('unsolved value list is empty!');
        return;
      }
      for (List<int> select in _unsolved) {
        for (int i = 0; i < containerSize.length - 1; i++) {
          setState(() {
            count++;
          });
          List<int> temp = List.from(select);
          temp.last += select[i];
          temp[i] = 0;
          if (temp.last > containerSize.last) {
            temp[i] = temp.last - containerSize.last;
            temp.last = temp.last - temp[i];
          }
          String n = temp.join(",");
          node.addIf(!node.containsKey(n), n, select);
          if (listEquals(temp.sublist(0, 4), target.sublist(0, 4))) {
            developer.log('solved!');
            solved = List.from(temp);
            break;
          }
          for (int j = 0; j < containerSize.length - 1; j++) {
            List<int> t = List.from(temp);
            t[j] += t.last;
            t.last = 0;
            if (t[j] > containerSize[j]) {
              t.last = t[j] - containerSize[j];
              t[j] -= t.last;
            }
            String r = t.join(",");
            if (!node.containsKey(r)) {
              node[r] = temp;
              unsolved.add(t);
            }
            if (listEquals(t.sublist(0, 4), target.sublist(0, 4))) {
              developer.log('solved!');
              solved = List.from(t);
              break;
            }
          }
          if (solved.isNotEmpty) {
            break;
          }
        }
        if (solved.isNotEmpty) {
          break;
        } else {
          unsolved.remove(select);
        }
      }
      if (solved.isNotEmpty) {
        break;
      }
    }
    result.add(solved);
    List<int> pick = List.from(solved);
    while (true) {
      String p = pick.join(",");
      if (node.containsKey(p)) {
        result.add(node[p]!);
        if (node[p] == container) {
          break;
        } else {
          pick = List.from(node[p]!);
        }
      } else {
        developer
            .log('cannot found key(container: $container, target: $target');
        setState(() {
          count = -1;
        });
        return;
      }
    }

    if (count > 0) {
      setState(() {
        result = List.from(result.reversed);
      });
    }
  }

  Widget orangeBox() {
    return Container(
      margin: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(5.0),
      ),
      width: 30,
      height: 30,
    );
  }

  Widget rotatedOrangeBox() {
    return RotationTransition(
      turns: const AlwaysStoppedAnimation(45 / 360),
      child: orangeBox(),
    );
  }

  Widget containerTextFormField(int index) {
    return SizedBox(
      width: 55,
      child: TextField(
        keyboardType: const TextInputType.numberWithOptions(),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^(\d?)')),
        ],
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            suffixText: '/${containerSize[index].toString()}'),
        onChanged: (value) {
          if (value.isEmpty) {
            setState(() {
              count = 0;
              container[index] = 0;
            });
          } else {
            setState(() {
              count = 0;
              container[index] = int.parse(value);
            });
          }
        },
      ),
    );
  }

  Widget targetTextFormField(int index) {
    return SizedBox(
      width: 55,
      child: TextField(
        enabled: index == 4 ? false : true,
        keyboardType: const TextInputType.numberWithOptions(),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^(\d?)')),
        ],
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          suffixText: '/${containerSize[index].toString()}',
        ),
        onChanged: (value) {
          if (value.isEmpty) {
            setState(() {
              count = 0;
              target[index] = 0;
            });
          } else {
            setState(() {
              count = 0;
              target[index] = int.parse(value);
            });
          }
        },
      ),
    );
  }

  Widget buildStatus() {
    if (count > 0) {
      return const Text(
        "연산이 완료되었습니다\n아래 지시를 순서대로 따라해주세요",
        textAlign: TextAlign.center,
      );
    }
    if (count < 0) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              child: Container(
                width: Size.infinite.width,
                alignment: Alignment.center,
                child: const Text('연산 시작'),
              ),
              onPressed: checkAndStart,
            ),
          ),
          const Text(
            "연산과정에서 오류가 발생했습니다\n입력값을 확인하고 다시 시도해주세요",
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton(
        child: Container(
          width: Size.infinite.width,
          alignment: Alignment.center,
          child: const Text('연산 시작'),
        ),
        onPressed: checkAndStart,
      ),
    );
  }

  Widget buildResult(int c, int t, int index) {
    if (c > t) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.arrow_downward,
            color: Colors.red,
          ),
          Text('$index번 기둥'),
          const Text('회수'),
        ],
      );
    }
    if (c < t) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.arrow_upward,
            color: Colors.blue,
          ),
          Text('$index번 기둥'),
          const Text('전송'),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.circle_outlined,
              color: Colors.white.withOpacity(0),
            ),
            const Text(''),
            const Text(''),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 1440,
            ),
            child: Column(
              children: [
                const Text(
                  '아토락시온 요루나키아 공략(Test)',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text('보름달에 뜬 눈물 계산기'),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      children: [
                        orangeBox(),
                        orangeBox(),
                        orangeBox(),
                      ],
                    ),
                    Column(
                      children: [
                        orangeBox(),
                        orangeBox(),
                        orangeBox(),
                        orangeBox(),
                      ],
                    ),
                    Column(
                      children: [
                        orangeBox(),
                        orangeBox(),
                        orangeBox(),
                        orangeBox(),
                        orangeBox(),
                        orangeBox(),
                      ],
                    ),
                    Column(
                      children: [
                        orangeBox(),
                        orangeBox(),
                        orangeBox(),
                        orangeBox(),
                        orangeBox(),
                        orangeBox(),
                        orangeBox(),
                      ],
                    ),
                    Column(
                      children: [
                        rotatedOrangeBox(),
                        rotatedOrangeBox(),
                        rotatedOrangeBox(),
                        rotatedOrangeBox(),
                        rotatedOrangeBox(),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Text('1번'),
                    Text('2번'),
                    Text('3번'),
                    Text('4번'),
                    Text('5번'),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.all(12.0),
                  child: const Text('현재 채워진 보름달'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    containerTextFormField(0),
                    containerTextFormField(1),
                    containerTextFormField(2),
                    containerTextFormField(3),
                    containerTextFormField(4),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  margin: const EdgeInsets.all(12.0),
                  child: const Text('목표 보름달'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    targetTextFormField(0),
                    targetTextFormField(1),
                    targetTextFormField(2),
                    targetTextFormField(3),
                    targetTextFormField(4),
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                buildStatus(),
                result.length > 3
                    ? ListView.separated(
                        separatorBuilder: (context, index) => const Divider(),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: result.length - 1,
                        itemBuilder: (BuildContext context, int index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildResult(
                                  result[index][0], result[index + 1][0], 1),
                              buildResult(
                                  result[index][1], result[index + 1][1], 2),
                              buildResult(
                                  result[index][2], result[index + 1][2], 3),
                              buildResult(
                                  result[index][3], result[index + 1][3], 4),
                              buildResult(0, 0, 5),
                            ],
                          );
                        },
                      )
                    : const SizedBox(),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
