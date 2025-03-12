import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter/material.dart';
import 'package:karanda/widgets/default_app_bar.dart';

class SycrakeaPage extends StatefulWidget {
  const SycrakeaPage({Key? key}) : super(key: key);

  @override
  _SycrakeaPageState createState() => _SycrakeaPageState();
}

class _SycrakeaPageState extends State<SycrakeaPage> {
  final List<List<int>> _board = [
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0],
  ];
  final List<List<int>> _result = [
    [0, 0, 0],
    [0, 1, 0],
    [0, 0, 0],
  ];

  void calculate() {
    setState(() {
      _result[0][0] =
          (_board[1][1] + _board[1][2] + _board[2][1] + _board[2][2]) % 2;
      _result[0][1] = (_board[1][0] +
              _board[1][1] +
              _board[1][2] +
              _board[2][0] +
              _board[2][1] +
              _board[2][2]) %
          2;
      _result[0][2] =
          (_board[1][0] + _board[1][1] + _board[2][0] + _board[2][1]) % 2;
      _result[1][0] = (_board[0][1] +
              _board[0][2] +
              _board[1][1] +
              _board[1][2] +
              _board[2][1] +
              _board[2][2]) %
          2;
      _result[1][1] = (_board[0][0] +
              _board[0][1] +
              _board[0][2] +
              _board[1][0] +
              _board[1][1] +
              _board[1][2] +
              _board[2][0] +
              _board[2][1] +
              _board[2][2] +
              1) %
          2;
      _result[1][2] = (_board[0][0] +
              _board[0][1] +
              _board[1][0] +
              _board[1][1] +
              _board[2][0] +
              _board[2][1]) %
          2;
      _result[2][0] =
          (_board[0][1] + _board[0][2] + _board[1][1] + _board[1][2]) % 2;
      _result[2][1] = (_board[0][0] +
              _board[0][1] +
              _board[0][2] +
              _board[1][0] +
              _board[1][1] +
              _board[1][2]) %
          2;
      _result[2][2] =
          (_board[0][0] + _board[0][1] + _board[1][0] + _board[1][1]) % 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const DefaultAppBar(
        title: "시카라키아 아홉문장 계산기",
        icon: FontAwesomeIcons.calculator,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Wrap(
            spacing: size.height > size.width
                ? size.height / 10
                : size.width / 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            direction:
            size.height > size.width ? Axis.vertical : Axis.horizontal,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15.0),
                    child: const Text(
                      '초록색 표시를 상호작용',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      children: List.generate(9, (index) {
                        return AnimatedContainer(
                          margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color: _result[index ~/ 3][index % 3] == 1
                                ? Colors.green
                                : Colors.white10,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          duration: const Duration(milliseconds: 150),
                          child: _result[index ~/ 3][index % 3] == 1
                              ? const Icon(
                              Icons.keyboard_arrow_down_rounded)
                              : const Icon(
                            Icons.adjust_outlined,
                            color: Colors.white10,
                          ),
                        );
                      }),
                    ),
                  ),
                  Container(
                    color: Colors.black38,
                    padding: const EdgeInsets.all(12.0),
                    margin: const EdgeInsets.all(18.0),
                    child: const Text(
                      '솔 마기아',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15.0),
                    child: const Text(
                      '현재 상태',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      children: List.generate(9, (index) {
                        return Container(
                          padding: const EdgeInsets.all(8.0),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              foregroundColor: Colors.white70,
                              backgroundColor:
                              _board[index ~/ 3][index % 3] == 1
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            child: _board[index ~/ 3][index % 3] == 1
                                ? const Icon(
                                Icons.keyboard_arrow_up_rounded)
                                : const Icon(
                                Icons.keyboard_arrow_down_rounded),
                            onPressed: () {
                              if (_board[index ~/ 3][index % 3] == 1) {
                                setState(() {
                                  _board[index ~/ 3][index % 3] = 0;
                                });
                              } else {
                                setState(() {
                                  _board[index ~/ 3][index % 3] = 1;
                                });
                              }
                              calculate();
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                  Container(
                    color: Colors.black38,
                    padding: const EdgeInsets.all(12.0),
                    margin: const EdgeInsets.all(18.0),
                    child: const Text(
                      '솔 마기아',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
