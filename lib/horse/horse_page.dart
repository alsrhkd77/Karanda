import 'package:black_tools/horse/horse_info.dart';
import 'package:black_tools/widgets/default_app_bar.dart';
import 'package:black_tools/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HorsePage extends StatefulWidget {
  const HorsePage({Key? key}) : super(key: key);

  @override
  State<HorsePage> createState() => _HorsePageState();
}

class _HorsePageState extends State<HorsePage> {
  String _horse = '꿈결 아두아나트';
  int level = 1;
  double _speed = 0;
  double _acceleration = 0;
  double _brake = 0;
  double _rotForce = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Wrap(
                spacing: 20.0,
                children: [
                  Container(
                    margin: EdgeInsets.all(12.0),
                    constraints: BoxConstraints(maxWidth: 720),
                    child: ExpansionTile(
                      title: const TitleText('종류'),
                      subtitle: Text(_horse),
                      children: [
                        Divider(),
                        ListTile(
                          title: Text('꿈결 환상마'),
                        ),
                        RadioListTile<String>(
                            title: Text('꿈결 아두아나트'),
                            value: '꿈결 아두아나트',
                            groupValue: _horse,
                            onChanged: (value) {
                              setState(() {
                                _horse = value!;
                              });
                            },
                        ),
                        RadioListTile<String>(
                          title: Text('꿈결 디네'),
                          value: '꿈결 디네',
                          groupValue: _horse,
                          onChanged: (value) {
                            setState(() {
                              _horse = value!;
                            });
                          },
                        ),
                        Divider(),
                        ListTile(
                          title: Text('환상마'),
                        ),
                        RadioListTile<String>(
                          title: Text('아두아나트'),
                          value: '아두아나트',
                          groupValue: _horse,
                          onChanged: (value) {
                            setState(() {
                              _horse = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('디네'),
                          value: '디네',
                          groupValue: _horse,
                          onChanged: (value) {
                            setState(() {
                              _horse = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('둠'),
                          value: '둠',
                          groupValue: _horse,
                          onChanged: (value) {
                            setState(() {
                              _horse = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(12.0),
                    constraints: BoxConstraints(maxWidth: 720),
                    child: ExpansionTile(
                      title: const TitleText('장비'),
                      children: [
                        Divider(),
                        ListTile(
                          title: Text('꿈결 환상마'),
                        ),
                        RadioListTile<String>(
                          title: Text('꿈결 아두아나트'),
                          value: '꿈결 아두아나트',
                          groupValue: _horse,
                          onChanged: (value) {
                            setState(() {
                              _horse = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('꿈결 디네'),
                          value: '꿈결 디네',
                          groupValue: _horse,
                          onChanged: (value) {
                            setState(() {
                              _horse = value!;
                            });
                          },
                        ),
                        Divider(),
                        ListTile(
                          title: Text('환상마'),
                        ),
                        RadioListTile<String>(
                          title: Text('아두아나트'),
                          value: '아두아나트',
                          groupValue: _horse,
                          onChanged: (value) {
                            setState(() {
                              _horse = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('디네'),
                          value: '디네',
                          groupValue: _horse,
                          onChanged: (value) {
                            setState(() {
                              _horse = value!;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('둠'),
                          value: '둠',
                          groupValue: _horse,
                          onChanged: (value) {
                            setState(() {
                              _horse = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(12.0),
                    constraints: BoxConstraints(maxWidth: 720),
                    child: ExpansionTile(
                      title: const TitleText('성장치'),

                      children: [
                        ListTile(
                          leading: Text('레벨'),
                          title: TextField(),
                          trailing: Text('기본: ${HorseInfo.detail[_horse]!['speed']}'),
                        ),
                        ListTile(
                          leading: Text('레벨'),
                          title: TextField(
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^(\d{0,3})?\.?\d{0,2}')),
                            ],
                          ),
                          trailing: Text(' 기본: ${HorseInfo.detail[_horse]!['속도']} '),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(12.0),
                    constraints: BoxConstraints(maxWidth: 720),
                    child: Card(
                      child: Container(
                        width: Size.infinite.width,
                        padding: EdgeInsets.all(12.0),
                        child: Text('결과'),
                      ),
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
