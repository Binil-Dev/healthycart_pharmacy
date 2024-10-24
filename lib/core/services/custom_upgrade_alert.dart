import 'dart:io';

import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

class CUpgradeAlert extends StatelessWidget {
  const CUpgradeAlert({
    super.key,
    required this.child,
    required this.minAppstoreVersion,
    required this.minPlaystoreVersion,
  });
  final Widget child;
  final String minAppstoreVersion;
  final String minPlaystoreVersion;

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      dialogStyle: UpgradeDialogStyle.cupertino,
      shouldPopScope: () => false,
      barrierDismissible: false,
      cupertinoButtonTextStyle: const TextStyle(
        color: Colors.black,
      ),
      upgrader: Upgrader(
        languageCode: 'en',
        minAppVersion:
            Platform.isIOS ? minAppstoreVersion : minPlaystoreVersion,
        durationUntilAlertAgain: const Duration(days: 2),
      ),
      child: child,
    );
  }
}
