import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart_pharmacy/core/custom/app_bar/custom_appbar_curve.dart';
import 'package:healthycart_pharmacy/core/custom/custom_alertbox/confirm_alertbox_widget.dart';
import 'package:healthycart_pharmacy/core/custom/lottie/circular_loading.dart';
import 'package:healthycart_pharmacy/core/custom/lottie/loading_lottie.dart';
import 'package:healthycart_pharmacy/core/services/easy_navigation.dart';
import 'package:healthycart_pharmacy/features/authenthication/application/authenication_provider.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/application/pharmacy_provider.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/presentation/pharmacy_product/product_pharmacy.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/presentation/product_category/widgets/add_new_round_widget.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/presentation/product_category/widgets/get_category_popup.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/presentation/product_category/widgets/round_text_widget.dart';
import 'package:healthycart_pharmacy/utils/constants/colors/colors.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class PharmacyCategoryScreen extends StatelessWidget {
  const PharmacyCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pharmacyProvider =
        Provider.of<PharmacyProvider>(context, listen: false);
    final mainProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (pharmacyProvider.pharmacyCategoryIdList.isEmpty) {
        pharmacyProvider.pharmacyCategoryIdList = mainProvider
                .pharmacyDataFetched!.selectedCategoryId ??
            []; // here we are passing the list of category id in the hospital admin side
        await pharmacyProvider.getpharmacyCategory();
      }
    });

    final PopupDoctorCategoryShower popup = PopupDoctorCategoryShower.instance;
    return Consumer<PharmacyProvider>(builder: (context, pharmacyProvider, _) {
      return CustomScrollView(
        slivers: [
          const CustomSliverCurveAppBarWidget(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pharmacy Categories',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  IconButton(
                    onPressed: () {
                      pharmacyProvider
                          .onTapEditButton(); // bool to toggle to edit
                    },
                    icon: pharmacyProvider.onTapBool
                        ? Text(
                            'Cancel Edit',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: BColors.red),
                          )
                        : Row(
                            children: [
                              Text(
                                'Edit',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                              ),
                              const Gap(4),
                              const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                  )
                ],
              ),
            ),
          ),
          if (pharmacyProvider.onTapBool)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Long press on the categories below to remove.',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
          (pharmacyProvider.fetchLoading)

              /// loading is done here
              ? const SliverFillRemaining(
                  child: Center(
                    child: LoadingIndicater(),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid.builder(
                    itemCount: pharmacyProvider.pharmacyCategoryList.length + 1,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                            mainAxisExtent: 128),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return AddNewRoundWidget(
                            title: 'Add New',
                            onTap: () {
                              //pharmacyProvider.removingFromUniqueCategoryList();
                              popup.showDoctorCategoryDialouge(
                                context: context,
                              );
                            });
                      } else {
                        final productCategory =
                            pharmacyProvider.pharmacyCategoryList[index - 1];
                        return VerticalImageText(
                            onTap: () {
                              pharmacyProvider.selectedProductType(
                                catId: productCategory.id ?? 'No ID',
                                selectedCategory: productCategory.category,
                              );
                              EasyNavigation.push(
                                type: PageTransitionType.rightToLeft,
                                context: context,
                                page: const PharmacyProductScreen(),
                              );
                            },
                            onLongPress: () {
                              ConfirmAlertBoxWidget.showAlertConfirmBox(
                                  context: context,
                                  titleText: 'Confirm to delete',
                                  subText: "Are you sure you want to delete?",
                                  confirmButtonTap: () async {
                                    LoadingLottie.showLoading(
                                        context: context,
                                        text: 'Please wait..');
                                    await pharmacyProvider
                                        .deletePharmacyCategory(
                                            index: index - 1,
                                            category: productCategory)
                                        .whenComplete(
                                      () {
                                        EasyNavigation.pop(context: context);
                                      },
                                    );
                                  });
                            },
                            image: productCategory.image,
                            title: productCategory.category);
                      }
                    },
                  ),
                )
        ],
      );
    });
  }
}
