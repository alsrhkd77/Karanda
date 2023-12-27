import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:karanda/auth/auth_notifier.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/widgets/default_app_bar.dart';
import 'package:karanda/widgets/loading_indicator_dialog.dart';
import 'package:karanda/widgets/title_text.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatefulWidget {
  final String? token;
  final String? refreshToken;
  const AuthPage({Key? key, required this.token, required this.refreshToken}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    super.initState();
    checkParam();
  }

  Future<void> checkParam() async {
    if (!Provider.of<AuthNotifier>(context, listen: false).authenticated) {
      String? token = widget.token;
      String? refreshToken = widget.refreshToken;
      if (token != null && refreshToken != null) {
        await Provider.of<AuthNotifier>(context, listen: false).saveToken(
            token: token, refreshToken: refreshToken);
        await Provider.of<AuthNotifier>(context, listen: false).authorization();
        context.go('/');
      }
    }
  }

  Future<void> unregister() async {
    bool check = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String targetText = 'UNREGISTER';
        bool check0 = false;
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter stateSetter) {
          return AlertDialog(
            title: const Text('회원 탈퇴'),
            contentPadding: const EdgeInsets.all(48.0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TitleText('주의 사항'),
                const SizedBox(
                  height: 12,
                ),
                const Text('1. 회원 탈퇴가 완료되면 즉시 회원님의 데이터가 삭제됩니다.'),
                const Text('2. 삭제된 데이터는 다시 복구할 수 없습니다.'),
                const SizedBox(
                  height: 24.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    maxLines: 1,
                    decoration: InputDecoration(
                        hintText: targetText,
                        border: const OutlineInputBorder()),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (value) {
                      value = value.toLowerCase();
                      if (value == targetText.toLowerCase()) {
                        stateSetter(() {
                          check0 = true;
                        });
                      } else {
                        stateSetter(() {
                          check0 = false;
                        });
                      }
                    },
                    validator: (value) {
                      value = value?.toLowerCase();
                      if (value != targetText.toLowerCase()) {
                        return targetText;
                      }
                      return null;
                    },
                  ),
                )
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('취소')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed:
                    check0 ? () => Navigator.of(context).pop(true) : null,
                child: const Text('확인'),
              ),
            ],
          );
        });
      },
    );
    if (check) {
      _showDialog('회원 탈퇴');
      bool status =
          await Provider.of<AuthNotifier>(context, listen: false).unregister();
      if (status) {
        context.pop();
        context.go('/');
      }
    }
  }

  Future<void> logout() async {
    _showDialog('로그아웃');
    await Provider.of<AuthNotifier>(context, listen: false).logout();
    context.pop();
    context.go('/');
  }

  void _showDialog(String title) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingIndicatorDialog(title: title,);
      },
    );
  }

  Widget _auth() {
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(
            maxWidth: 400.0,
            maxHeight: 400.0,
          ),
          margin: const EdgeInsets.all(40.0),
          child: Image.asset(
            'assets/brand/karanda_mix.png',
            filterQuality: FilterQuality.high,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              fixedSize: const Size.fromWidth(500),
            ),
            icon: const Icon(
              FontAwesomeIcons.discord,
              color: Color.fromRGBO(88, 101, 242, 1),
            ),
            onPressed: () {
              Provider.of<AuthNotifier>(context, listen: false).authenticate();
            },
            label: const Text(' 디스코드로 로그인'),
          ),
        ),
      ],
    );
  }

  Widget _userInfo() {
    String username =
        Provider.of<AuthNotifier>(context, listen: false).username;
    String avatar = Provider.of<AuthNotifier>(context, listen: false).avatar;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const ListTile(
              title: TitleText(
                '로그인 정보',
                bold: true,
              ),
            ),
            Container(
              constraints: const BoxConstraints(
                maxWidth: 300,
                maxHeight: 300,
              ),
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage('${Api.discordCDN}$avatar'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const ListTile(
              iconColor: Color.fromRGBO(88, 101, 242, 1),
              leading: Text('플랫폼'),
              title: Text('Discord'),
              trailing: Icon(FontAwesomeIcons.discord),
            ),
            const Divider(),
            ListTile(
              leading: const Text('닉네임'),
              title: Text(username),
            ),
            const Divider(),
            ListTile(
              textColor: Colors.orange,
              iconColor: Colors.orange,
              onTap: () => logout(),
              title: const Text('로그아웃'),
              trailing: const Icon(Icons.logout),
            ),
            const Divider(),
            ListTile(
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () => unregister(),
              title: const Text('회원 탈퇴'),
              trailing: const Icon(Icons.delete_forever_outlined),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(12.0),
            width: Size.infinite.width,
            constraints: const BoxConstraints(
              maxWidth: 700,
            ),
            child: Provider.of<AuthNotifier>(context).authenticated
                ? _userInfo()
                : _auth(),
          ),
        ),
      ),
    );
  }
}
