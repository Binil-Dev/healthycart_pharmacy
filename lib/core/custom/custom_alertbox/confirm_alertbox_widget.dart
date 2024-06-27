import 'package:flutter/material.dart';
import 'package:healthycart_pharmacy/core/services/easy_navigation.dart';
import 'package:healthycart_pharmacy/utils/constants/colors/colors.dart';

class ConfirmAlertBoxWidget {
  static void showAlertConfirmBox(
      {required BuildContext context,
      required VoidCallback confirmButtonTap,
      required String titleText,
      required String subText}) async{
    await showDialog(
      context: context,
      builder: (context) {
        return SizedBox(
          width: 260,
          height: 300,
          child: AlertDialog(
             backgroundColor: BColors.white,
            title:
                Text(titleText, style: Theme.of(context).textTheme.bodyLarge),
            content: Text(subText,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
            actions: [
              TextButton(
                  onPressed: () {
                    EasyNavigation.pop(context: context);
                  },
                  child: const Text(
                    'No',
                    style: TextStyle(color: BColors.darkblue),
                  )),
              ElevatedButton(
                onPressed: () {
                  EasyNavigation.pop(context: context);
                  confirmButtonTap.call();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: BColors.mainlightColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: Text('Yes',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}
