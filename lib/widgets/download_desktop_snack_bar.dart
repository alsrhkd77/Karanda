import 'package:flutter/material.dart';
import 'package:karanda/common/api.dart';
import 'package:karanda/common/global_properties.dart';
import 'package:karanda/common/launch_url.dart';

class DownloadDesktopSnackBar {
  DownloadDesktopSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(
              Icons.install_desktop,
            ),
            SizedBox(
              width: 8.0,
            ),
            Text('Desktop에서 이용할 수 있습니다'),
          ],
        ),
        action: SnackBarAction(
          onPressed: () => launchURL(Api.latestInstaller),
          label: '다운로드',
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: GlobalProperties.snackBarMargin,
        showCloseIcon: false,
      ),
    );
  }
}
