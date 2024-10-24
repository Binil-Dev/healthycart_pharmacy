import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:healthycart_pharmacy/core/di/injection.dart';
import 'package:healthycart_pharmacy/core/services/foreground_notification.dart';
import 'package:healthycart_pharmacy/features/add_pharmacy_form_page/application/pharmacy_form_provider.dart';
import 'package:healthycart_pharmacy/features/authenthication/application/authenication_provider.dart';
import 'package:healthycart_pharmacy/features/bulk_product_upload.dart/application/bpu_provider.dart';
import 'package:healthycart_pharmacy/features/general/data/i_general_facade.dart';
import 'package:healthycart_pharmacy/features/general/presentation/provider/general_provider.dart';
import 'package:healthycart_pharmacy/features/pharmacy_banner/application/add_banner_provider.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/application/pharmacy_provider.dart';
import 'package:healthycart_pharmacy/features/pharmacy_profile/application/profile_provider.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/application/provider/request_pharmacy_provider.dart';
import 'package:healthycart_pharmacy/features/location_picker/application/location_provider.dart';
import 'package:healthycart_pharmacy/features/pending_page/application/pending_provider.dart';
import 'package:healthycart_pharmacy/features/splash_screen/splash_screen.dart';
import 'package:healthycart_pharmacy/main.dart';
import 'package:healthycart_pharmacy/utils/theme/theme.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App(
      {super.key,required this.androidNotificationChannel,required this.flutterLocalNotificationsPlugin});
  final AndroidNotificationChannel androidNotificationChannel;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    ForegroundNotificationService.foregroundNotitficationInit(
        channel: widget.androidNotificationChannel,
        flutterLocalNotificationsPlugin: widget.flutterLocalNotificationsPlugin);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => sl<PharmacyFormProvider>(),
        ),
        ChangeNotifierProvider(
          create: (context) => sl<PharmacyProvider>(),
        ),
        ChangeNotifierProvider(
          create: (context) => sl<RequestPharmacyProvider>(),
        ),
        ChangeNotifierProvider(
          create: (context) => sl<AddBannerProvider>(),
        ),
        ChangeNotifierProvider(
          create: (context) => sl<LocationProvider>(),
        ),
        ChangeNotifierProvider(
          create: (context) => sl<AuthenticationProvider>(),
        ),
        ChangeNotifierProvider(
          create: (context) => sl<PendingProvider>(),
        ),
        ChangeNotifierProvider(
          create: (context) => sl<ProfileProvider>(),
        ),
        ChangeNotifierProvider(
          create: (context) => sl<BPUProvider>(),
        ),
      ChangeNotifierProvider(
          create: (context) => GeneralProvider(sl<IGeneralFacade>()),)
      ],
      child: MaterialApp(
          builder: (context, child) => Overlay(
                initialEntries: [
                  if (child != null) ...[
                    OverlayEntry(
                      builder: (context) => child,
                    ),
                  ],
                ],
              ),
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.light,
          theme: BAppTheme.lightTheme,
          darkTheme: BAppTheme.darkTheme,
          home: const SplashScreen(),
          ),
    );
  }
}
