import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:healthycart_pharmacy/main.dart';
import 'package:healthycart_pharmacy/utils/constants/colors/colors.dart';

// class CustomToast {
//   // final BuildContext context;
//   // static BuildContext? currentContext;
//   // CustomToast(this.context) {
//   //   currentContext = context;
//   // }


// static void sucessToast({required String text}) {
//   Fluttertoast.showToast(
//       msg: text,
//       toastLength: Toast.LENGTH_LONG,
//       gravity: ToastGravity.BOTTOM,
//       timeInSecForIosWeb: 2,
//       backgroundColor: BColors.buttonLightColor,
//       textColor: Colors.white,
//       fontSize: 16.0);
// }

// static void errorToast({required String text}) {
//   Fluttertoast.showToast(
//       msg: text,
//       toastLength: Toast.LENGTH_LONG,
//       gravity: ToastGravity.BOTTOM,
//       timeInSecForIosWeb: 2,
//       backgroundColor: BColors.red,
//       textColor: Colors.white,
//       fontSize: 16.0);
// }


// }


class CustomToast {
  // static BuildContext? currentContext;
  // final BuildContext context;

  // CustomToast({required this.context}) {
  //   currentContext = context;
  // }

  static void sucessToast({required String text}) {
    FToast ftoast = FToast();
    ftoast.init(navigatorKey.currentContext!);

    Widget toast = Container(
      // width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green[500],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Flexible(
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: BColors.white, fontWeight: FontWeight.w500)),
      ),
    );

    ftoast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(milliseconds: 1500),
    );
  }

  static void errorToast({required String text}) {
    FToast ftoast = FToast();
    ftoast.init(navigatorKey.currentContext!);

    Widget toast = Container(
      // width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      decoration: BoxDecoration(
        color: Colors.red[600],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: BColors.white, fontWeight: FontWeight.w500)),
    );

    ftoast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(milliseconds: 1500),
    );
  }
}
