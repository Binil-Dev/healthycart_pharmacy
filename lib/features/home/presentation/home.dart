import 'package:flutter/material.dart';
import 'package:healthycart_pharmacy/core/custom/bottom_navigation/bottom_nav_widget.dart';
import 'package:healthycart_pharmacy/features/authenthication/application/authenication_provider.dart';
import 'package:healthycart_pharmacy/features/pharmacy_banner/presentation/banner_page.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/presentation/product_category/product_category.dart';
import 'package:healthycart_pharmacy/features/pharmacy_profile/presentation/profile_screen.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/presentation/request_page.dart';
import 'package:healthycart_pharmacy/utils/constants/image/icon.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
        final authProvider = Provider.of<AuthenticationProvider>(context);
    return PopScope(
      canPop:authProvider.canPopNow,
      onPopInvoked: authProvider.onPopInvoked,
      child: Scaffold(
          bottomNavigationBar: BottomNavigationWidget(
        text1: 'Orders',
        text2: 'Product',
        text3: 'Banner',
        text4: 'Profile',
        tabItems: const [
          RequestScreen(),
          PharmacyCategoryScreen(),
          BannerScreen(),
          ProfileScreen(),
        ],
        selectedImage1: Image.asset(
          BIcon.order,
          height: 30,
          width: 30,
        ),
        unselectedImage1: Image.asset(
          BIcon.orderBlack,
          height: 28,
          width: 28,
        ),
        selectedImage2: Image.asset(
          BIcon.addPharmacyProduct,
          height: 28,
          width: 28,
        ),
        unselectedImage2: Image.asset(
          BIcon.addPharmacyProductBlack,
          height: 24,
          width: 24,
        ),
      )),
    );
  }
}
