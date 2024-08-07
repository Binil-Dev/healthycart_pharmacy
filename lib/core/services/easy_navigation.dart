import 'package:flutter/material.dart';
import 'package:healthycart_pharmacy/main.dart';
import 'package:page_transition/page_transition.dart';


class EasyNavigation {
  static Future<void> push({
    required BuildContext context,
    required Widget page,
    PageTransitionType type = PageTransitionType.fade,
  }) async {
    await Navigator.push(
      context,
      PageTransition(
        child: page,
        type: type,
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  static Future<void> pushReplacement({
    required BuildContext context,
    required Widget page,
    PageTransitionType type = PageTransitionType.fade,
  }) async {
    await Navigator.pushReplacement(
      context,
      PageTransition(
        child: page,
        type: type,
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 300),
      ),
    );
  }
  static Future<void> pushAndRemoveUntil({
    required BuildContext context,
    required Widget page,
    PageTransitionType type = PageTransitionType.fade,
  }) async {
    await Navigator.pushAndRemoveUntil(
      context,
      PageTransition(
        child: page,
        type: type,
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 300),
      ),
      (Route<dynamic> route) => false,
    );
  }
  static Future<void> pop({
    required BuildContext context,
  }) async {
    Navigator.of(navigatorKey.currentState?.context ?? context).pop();
  }
}
