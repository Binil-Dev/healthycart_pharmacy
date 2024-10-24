import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart_pharmacy/core/custom/app_bar/custom_appbar_curve.dart';
import 'package:healthycart_pharmacy/core/custom/custom_alertbox/confirm_alertbox_widget.dart';
import 'package:healthycart_pharmacy/core/custom/lottie/loading_lottie.dart';
import 'package:healthycart_pharmacy/core/services/easy_navigation.dart';
import 'package:healthycart_pharmacy/features/authenthication/application/authenication_provider.dart';
import 'package:healthycart_pharmacy/features/bulk_product_upload.dart/presentation/bpu_category.dart';
import 'package:healthycart_pharmacy/features/pharmacy_profile/application/profile_provider.dart';
import 'package:healthycart_pharmacy/features/pharmacy_profile/presentation/product_list_profile/product_list.dart';
import 'package:healthycart_pharmacy/features/pharmacy_profile/presentation/transaction/payment_history_tab.dart';
import 'package:healthycart_pharmacy/features/pharmacy_profile/presentation/widget/contact_us_sheet.dart';
import 'package:healthycart_pharmacy/features/pharmacy_profile/presentation/widget/profile_header_widget.dart';
import 'package:healthycart_pharmacy/features/pharmacy_profile/presentation/widget/profile_main_container_widget.dart';
import 'package:healthycart_pharmacy/utils/constants/colors/colors.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthenticationProvider, ProfileProvider>(
        builder: (context, authProviderPharamacyDetails, profileProvider, _) {
      return CustomScrollView(
        slivers: [
          const CustomSliverCurveAppBarWidget(),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Gap(6),
                  const ProfileHeaderWidget(),
                  const Gap(8),
                  ProfileMainContainer(
                    text: 'Pharmacy On / Off',
                    sideChild: LiteRollingSwitch(
                      value: authProviderPharamacyDetails
                              .pharmacyDataFetched?.isPharmacyON ??
                          false,
                      width: 80,
                      textOn: 'On',
                      textOff: 'Off',
                      colorOff: Colors.grey.shade400,
                      colorOn: BColors.mainlightColor,
                      iconOff: Icons.block_rounded,
                      iconOn: Icons.power_settings_new,
                      animationDuration: const Duration(milliseconds: 300),
                      onChanged: (bool ispharmacyON) async {
                         LoadingLottie.showLoading(
                            context: context, text: 'Please wait...');
                        profileProvider.pharmacyStatus(ispharmacyON);
                        await profileProvider.setActivePharmacy().whenComplete(
                          () {
                            EasyNavigation.pop(context: context);
                          },
                        );
                      },
                      onDoubleTap: () {},
                      onSwipe: () {},
                      onTap: () {},
                    ),
                  ),
                  const Gap(4),
                  ProfileMainContainer(
                    text: 'Home Delivery On / Off',
                    sideChild: LiteRollingSwitch(
                      value: authProviderPharamacyDetails
                              .pharmacyDataFetched?.isHomeDelivery ??
                          false,
                      width: 80,
                      textOn: 'On',
                      textOff: 'Off',
                      colorOff: Colors.grey.shade400,
                      colorOn: BColors.mainlightColor,
                      iconOff: Icons.block_rounded,
                      iconOn: Icons.power_settings_new,
                      animationDuration: const Duration(milliseconds: 300),
                      onChanged: (bool isHomeDeliveryON) async {
                        profileProvider.homeDeliveryStatus(isHomeDeliveryON);
                        LoadingLottie.showLoading(
                            context: context, text: 'Please wait...');
                        await profileProvider
                            .setPharmacyHomeDelivery()
                            .whenComplete(
                          () {
                            EasyNavigation.pop(context: context);
                          },
                        );
                      },
                      onDoubleTap: () {},
                      onSwipe: () {},
                      onTap: () {},
                    ),
                  ),
                     const Gap(4),
                  GestureDetector(
                    onTap: () {
                       EasyNavigation.push(
                          context: context,
                          type: PageTransitionType.rightToLeft,
                          page: const BPUCategoryScreen(),);
                    },
                    child: const ProfileMainContainer(
                        text: 'Bulk Product Upload',
                        sideChild: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_forward_ios),
                        )),
                  ),
                  const Gap(4),
                  GestureDetector(
                    onTap: () {
                     EasyNavigation.push(
                          context: context,
                          type: PageTransitionType.rightToLeft,
                          page: const PharmacyProfileProductList());
                    },
                    child: const ProfileMainContainer(
                        text: 'Product List',
                        sideChild: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_forward_ios),
                        )),
                  ),
                  const Gap(4),
                  GestureDetector(
                    onTap: () {
                 EasyNavigation.push(
                          context: context,
                          type: PageTransitionType.rightToLeft,
                          page: const PaymentsScreen());
                    },
                    child: const ProfileMainContainer(
                        text: 'Payment History',
                        sideChild: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_forward_ios),
                        )),
                  ),
                 
                   const Gap(4),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        backgroundColor: BColors.white,
                        barrierColor: BColors.black.withOpacity(0.5),
                        elevation: 5,
                        showDragHandle: true,
                        context: context,
                        builder: (context) =>  ContactUsBottomSheet(message:  'Hi, I am reaching out from ${authProviderPharamacyDetails.pharmacyDataFetched?.pharmacyName}',),
                      );
                    },
                    child: const ProfileMainContainer(
                        text: 'Contact Us',
                        sideChild: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_forward_ios),
                        )),
                  ),

                  const Gap(4),
                  GestureDetector(
                    onTap: () {
                      ConfirmAlertBoxWidget.showAlertConfirmBox(
                          context: context,
                          confirmButtonTap: () async {
                            LoadingLottie.showLoading(
                                context: context, text: 'Logging out..');
                            await authProviderPharamacyDetails.pharmacyLogOut(
                                context: context);
                          },
                          titleText: 'Confirm to Log Out',
                          subText: 'Are you sure to Log Out ?');
                    },
                    child: const ProfileMainContainer(
                        text: 'Log Out',
                        sideChild: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.logout),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
