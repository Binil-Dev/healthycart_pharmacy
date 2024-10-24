import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:healthycart_pharmacy/core/custom/toast/toast.dart';
import 'package:healthycart_pharmacy/core/services/easy_navigation.dart';
import 'package:healthycart_pharmacy/features/add_pharmacy_form_page/domain/model/pharmacy_model.dart';
import 'package:healthycart_pharmacy/features/add_pharmacy_form_page/presentation/pharmacy_form.dart';
import 'package:healthycart_pharmacy/features/authenthication/domain/i_auth_facade.dart';
import 'package:healthycart_pharmacy/features/authenthication/presentation/otp_ui.dart';
import 'package:healthycart_pharmacy/features/home/presentation/home.dart';
import 'package:healthycart_pharmacy/features/location_picker/presentation/location.dart';
import 'package:healthycart_pharmacy/features/pending_page/presentation/pending_page.dart';
import 'package:healthycart_pharmacy/features/splash_screen/splash_screen.dart';
import 'package:injectable/injectable.dart';
import 'package:page_transition/page_transition.dart';

@injectable
class AuthenticationProvider extends ChangeNotifier {
  AuthenticationProvider(this.iAuthFacade);
  final IAuthFacade iAuthFacade;
  PharmacyModel? pharmacyDataFetched;
  String? smsCode;
  final TextEditingController phoneNumberController = TextEditingController();
  String? countryCode;
  String? phoneNumber;
  String? pharmacyId;
  int? isRequsetedPendingPage;

  void setNumber() {
    phoneNumber = '$countryCode${phoneNumberController.text.trim()}';
    notifyListeners();
  }

  Future<void> pharmacyStreamFetchedData() async {
    final completer = Completer<void>();
    final result = iAuthFacade.pharmacyStreamFetchedData();
    result.listen((event) {
      pharmacyDataFetched = event;
      isRequsetedPendingPage = event?.pharmacyRequested;
      notifyListeners();
      if (!completer.isCompleted) {
        completer.complete();
      }
    }, onError: (error) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    });
    await completer.future;
  }

  void navigationPharmacyFuction({required BuildContext context}) async {
    if (pharmacyDataFetched?.pharmacyAddress == null ||
        pharmacyDataFetched?.pharmacyImage == null ||
        pharmacyDataFetched?.pharmacyName == null ||
        pharmacyDataFetched?.pharmacyDocumentLicense == null ||
        pharmacyDataFetched?.email == null ||
        pharmacyDataFetched?.pharmacyownerName == null) {
      EasyNavigation.pushReplacement(
        type: PageTransitionType.bottomToTop,
        context: context,
        page: PharmacyFormScreen(
          pharmacyModel: pharmacyDataFetched,
          isEditing: false,
        ),
      );
      notifyListeners();
    } else if (pharmacyDataFetched?.placemark == null) {
      EasyNavigation.pushReplacement(
        type: PageTransitionType.bottomToTop,
        context: context,
        page: const LocationPage(),
      );
      notifyListeners();
    } else if ((pharmacyDataFetched?.pharmacyRequested == 0 ||
            pharmacyDataFetched?.pharmacyRequested == 1) &&
        pharmacyDataFetched?.placemark != null) {
      EasyNavigation.pushReplacement(
          type: PageTransitionType.bottomToTop,
          context: context,
          page: const PendingPageScreen());
      notifyListeners();
    } else {
      EasyNavigation.pushAndRemoveUntil(
          type: PageTransitionType.bottomToTop,
          context: context,
          page: const HomeScreen());
      notifyListeners();
    }
  }

  void verifyPhoneNumber(
      {required BuildContext context, required bool resend}) {
    iAuthFacade.verifyPhoneNumber(phoneNumber!).listen((result) {
      result.fold((failure) {
        Navigator.pop(context);
        CustomToast.errorToast(text: failure.errMsg);
      }, (isVerified) {
        Navigator.pop(context);
        if (resend == false) {
          EasyNavigation.push(
              type: PageTransitionType.rightToLeft,
              context: context,
              page: OTPScreen(
                phoneNumber: phoneNumber ?? 'No Number',
              ));
        }
      });
    });
  }

  Future<void> verifySmsCode(
      {required String smsCode, required BuildContext context}) async {
    final result = await iAuthFacade.verifySmsCode(smsCode: smsCode);
    result.fold((failure) {
      Navigator.pop(context);
      CustomToast.errorToast(text: failure.errMsg);
    }, (userId) {
      userId = userId;
      Navigator.pop(context);
      EasyNavigation.pushReplacement(
          context: context, page: const SplashScreen());
      phoneNumberController.clear();
    });
  }

  Future<void> pharmacyLogOut({required BuildContext context}) async {
    final result = await iAuthFacade.pharmacyLogOut();
    result.fold((failure) {
      EasyNavigation.pop(context: context);
      CustomToast.errorToast(text: failure.errMsg);
    }, (sucess) {
      EasyNavigation.pop(context: context);
      CustomToast.sucessToast(text: sucess);
      EasyNavigation.pushReplacement(
          context: context, page: const SplashScreen());
    });
  }

/* ------------------------------ NOTIFICATION ------------------------------ */

  Future<void> notificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('User granted provisional permission');
    } else {
      log('User declined or has not accepted permission');
    }
    notifyListeners();
  }

/* ------------------------------ EXIT FROM APP ----------------------------- */
  DateTime? currentBackPressTime;
  int requiredSeconds = 2;
  bool canPopNow = false;

  void onPopInvoked(bool didPop) {
    DateTime currentTime = DateTime.now();
    if (currentBackPressTime == null ||
        currentTime.difference(currentBackPressTime!) >
            Duration(seconds: requiredSeconds)) {
      currentBackPressTime = currentTime;
      CustomToast.errorToast(text: 'Press again to exit');
      Future.delayed(
        Duration(seconds: requiredSeconds),
        () {
          canPopNow = false;
          notifyListeners();
        },
      );

      canPopNow = true;
      notifyListeners();
    }
  }
}
