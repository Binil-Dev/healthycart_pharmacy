import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart_pharmacy/core/custom/custom_buttons_and_search/common_button.dart';
import 'package:healthycart_pharmacy/core/custom/lottie/loading_lottie.dart';
import 'package:healthycart_pharmacy/features/authenthication/application/authenication_provider.dart';
import 'package:healthycart_pharmacy/features/authenthication/presentation/widget/pinput.dart';
import 'package:healthycart_pharmacy/utils/constants/colors/colors.dart';
import 'package:healthycart_pharmacy/utils/constants/image/image.dart';
import 'package:provider/provider.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen(
      {super.key,  required this.phoneNumber});
 
  final String phoneNumber;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late int seconds;
  int resendTimer = 30;
  Timer? timer;
  @override
  void initState() {
    seconds = resendTimer;
    setTimer();
    super.initState();
  }

  void setTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
         appBar: AppBar(
          backgroundColor: Colors.transparent,

          surfaceTintColor: BColors.white,
          leading:                      GestureDetector(
                        // back to previous page
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back_ios),
                      ) ,
         ),
        resizeToAvoidBottomInset: true,
        body: Consumer<AuthenticationProvider>(
            builder: (context, authenticationProvider, _) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    
                      SizedBox(
                        child: Center(
                          child: Image.asset(
                              height: 280, width: 218, BImage.otpImage),
                        ),
                      ),
                      const Gap(40),
                      Text(
                        'Verification',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.w700, fontSize: 28),
                      ),
                      const Gap(16),
                      SizedBox(
                          width: 300,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                    text:
                                        'Please enter the One Time Password we sent via message ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(fontWeight: FontWeight.w600)),
                                TextSpan(
                                  text: widget.phoneNumber,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black),
                                ),
                              ],
                            ),
                          )),
                      const Gap(40),
                      PinputWidget(
                          onSubmitted: (_) {}, controller: otpController),
                      const Gap(40),
                      CustomButton(
                        width: double.infinity,
                        height: 48,
                        onTap: () {
                          LoadingLottie.showLoading(
                              context: context, text: 'Loading...');
                          authenticationProvider.verifySmsCode(
                              smsCode: otpController.text.trim(),
                              context: context);
                        },
                        text: 'Verify code',
                        buttonColor: BColors.buttonLightColor,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .copyWith(fontSize: 18, color: BColors.white),
                      ),
                      const Gap(24),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: "Didn't get OTP ? ",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    )),
                            (seconds == 0)
                                ? TextSpan(
                                    text: 'Resend',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                          decoration: TextDecoration.underline,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        LoadingLottie.showLoading(
                                            context: context, text: 'Loading...');
                                        authenticationProvider.verifyPhoneNumber(
                                          resend: true,
                                            context: context);
                                      })
                                : TextSpan(
                                    text: 'in 00:$seconds',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        }));
  }
}
