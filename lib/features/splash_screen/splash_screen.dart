import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:healthycart_pharmacy/core/services/easy_navigation.dart';
import 'package:healthycart_pharmacy/features/authenthication/application/authenication_provider.dart';
import 'package:healthycart_pharmacy/features/authenthication/presentation/login_ui.dart';
import 'package:healthycart_pharmacy/features/general/presentation/provider/general_provider.dart';
import 'package:healthycart_pharmacy/utils/constants/image/image.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    context.read<AuthenticationProvider>().notificationPermission();
    final authProvider = context.read<AuthenticationProvider>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await context.read<GeneralProvider>().fetchData();

         authProvider.pharmacyStreamFetchedData()
          .whenComplete(
        () {
          Future.delayed(const Duration(seconds: 4), () {
          
            if (authProvider.pharmacyDataFetched == null) {
              EasyNavigation.pushReplacement(
                  context: context, page: const LoginScreen());
            } else {
              
                authProvider.navigationPharmacyFuction(context: context);
            }
          });
        },
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Animate(
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ////////////////// LOGO ////////////////
                      Image.asset(
                        BImage.roundedSplashLogo,
                        height: 100,
                        width: 100,
                      ),
                      const Gap(22),
                      /////////////////// TEXT UNDER LOGO ///////////
                      Image.asset(
                        BImage.healthycartText,
                        height: 10,
                        width: 114,
                      )
                    ],
                  )
                          .animate()
                          .slideY(
                            begin: -100,
                            curve: Curves.decelerate,
                            delay: const Duration(seconds: 0),
                            duration: const Duration(milliseconds: 1500),
                          )
                          .shake(
                              rotation: 0,
                              duration: const Duration(milliseconds: 1000),
                              offset: const Offset(0, 150),
                              delay: const Duration(milliseconds: 1300),
                              hz: 0.5,
                              curve: Curves.decelerate)
                          .shakeY(
                            curve: Curves.decelerate,
                            delay: const Duration(milliseconds: 2000),
                            duration: const Duration(milliseconds: 1000),
                            hz: 1,
                          )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
