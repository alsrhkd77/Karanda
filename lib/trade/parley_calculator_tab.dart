import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karanda/trade/advanced_parley_calculator.dart';
import 'package:karanda/trade/normal_parley_calculator.dart';
import 'package:karanda/widgets/loading_indicator.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParleyCalculatorTab extends StatefulWidget {
  const ParleyCalculatorTab({Key? key}) : super(key: key);

  @override
  State<ParleyCalculatorTab> createState() => _ParleyCalculatorTabState();
}

class _ParleyCalculatorTabState extends State<ParleyCalculatorTab> {
  late bool _formType;

  Future<void> saveFormType(bool value) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setBool('parley calculator form type', value);
  }

  Future<bool> getFormType() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    _formType = sharedPreferences.getBool('parley calculator form type') ?? false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getFormType(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingIndicator();
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(FontAwesomeIcons.solidHandshake),
                title: const TitleText(
                  '교섭력 계산기',
                  bold: true,
                ),
                trailing: IconButton(
                  onPressed: () {
                    saveFormType(!_formType);
                    setState(() {
                      _formType = !_formType;
                    });
                  },
                  icon: Icon(Icons.dynamic_form_outlined, color: _formType ? Colors.blue : null,),
                ),
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: _formType ? const AdvancedParleyCalculator() : const NormalParleyCalculator(),
              ),
            ],
          ),
        );
      },
    );
  }
}
