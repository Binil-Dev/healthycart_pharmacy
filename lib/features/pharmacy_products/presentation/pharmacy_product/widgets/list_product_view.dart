import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart_pharmacy/core/custom/custom_cached_network/custom_cached_network_image.dart';
import 'package:healthycart_pharmacy/core/custom/lottie/loading_lottie.dart';
import 'package:healthycart_pharmacy/core/custom/pop_over/pop_over.dart';
import 'package:healthycart_pharmacy/core/services/easy_navigation.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/application/pharmacy_provider.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/presentation/pharmacy_product/widgets/forms_widget/equipment_add_form.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/presentation/pharmacy_product/widgets/forms_widget/medicine_add_form.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/presentation/pharmacy_product/widgets/forms_widget/other_add_form.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/presentation/pharmacy_product/widgets/percentage_container.dart';
import 'package:healthycart_pharmacy/utils/constants/colors/colors.dart';
import 'package:healthycart_pharmacy/utils/constants/image/image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ProductListWidget extends StatelessWidget {
  const ProductListWidget({
    super.key,
    required this.index,
  });
  final int index;
  @override
  Widget build(BuildContext context) {
    return Consumer<PharmacyProvider>(builder: (context, pharmacyProvider, _) {
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Material(
              surfaceTintColor: BColors.white,
              color: BColors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  
                  children: [
                    Container(
                      height: 96,
                      width: 96,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: (pharmacyProvider
                                .productList[index].productImage != null)
                            ? CustomCachedNetworkImage(
                                image: pharmacyProvider
                                        .productList[index].productImage?[0] ??
                                    '',
                                fit: BoxFit.contain,
                              )
                            : Image.asset(BImage.roundLogo)
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Gap(12),
                            Text(
                              pharmacyProvider.productList[index].productName ??
                                  'Unknown Name',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: 'by : ', // remeber to put space
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: BColors.textLightBlack),
                                ),
                                TextSpan(
                                  text: pharmacyProvider
                                      .productList[index].productBrandName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                ),
                              ]),
                            ),
                            const Gap(4),
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                text: 'Product type : ', // remeber to put space
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: BColors.textLightBlack),
                              ),
                              TextSpan(
                                text: pharmacyProvider
                                    .productList[index].typeOfProduct,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(
                                        color: BColors.mainlightColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                              ),
                            ])),
                            const Gap(4),
                            (pharmacyProvider.productList[index]
                                        .productDiscountRate ==
                                    null)
                                ? RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: 'Our price : ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .copyWith(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: BColors.textLightBlack),
                                      ),
                                      TextSpan(
                                          text: "₹ ",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge!
                                              .copyWith(
                                                  fontSize: 12,
                                                  color: BColors.green,
                                                  fontWeight: FontWeight.w600)),
                                      TextSpan(
                                        text:
                                            "${pharmacyProvider.productList[index].productMRPRate} ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .copyWith(
                                                fontSize: 12,
                                                color: BColors.green,
                                                fontWeight: FontWeight.w600),
                                      ),
                                    ]),
                                  )
                                : RichText(
                                    text: TextSpan(children: [
                                    TextSpan(
                                      text: 'Our price : ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: BColors.textLightBlack),
                                    ),
                                    TextSpan(
                                        text: "₹ ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .copyWith(
                                                fontSize: 12,
                                                color: BColors.green,
                                                fontWeight: FontWeight.w700)),
                                    TextSpan(
                                      text:
                                          "${pharmacyProvider.productList[index].productDiscountRate} ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(
                                              color: BColors.green,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700),
                                    ),
                                    
                                    TextSpan(
                                      text:
                                          "${pharmacyProvider.productList[index].productMRPRate}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(
                                              fontSize: 12,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationThickness: 2.0,
                                              fontWeight: FontWeight.w700),
                                    ),
                                  ])),
                            const Gap(8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                (pharmacyProvider.productList[index]
                                            .productDiscountRate !=
                                        null)
                                    ? PercentageShowContainerWidget(
                                        text:
                                            '${pharmacyProvider.productList[index].discountPercentage}% off',
                                        textColor: BColors.white,
                                        boxColor: BColors.offRed,
                                        width: 72,
                                        height: 24,
                                      )
                                    : const SizedBox(
                                        height: 24,
                                        width: 72,
                                      ),
                                Row(
                                  children: [
                                    Text(
                                      'In Stock :',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600),
                                    ),
                                    const Gap(8),
                                    SizedBox(
                                        height: 24,
                                        width: 48,
                                        child: FittedBox(
                                            fit: BoxFit.cover,
                                            child: Switch(
                                              inactiveThumbColor:
                                                  BColors.offRed,
                                              inactiveTrackColor: BColors.white,
                                              activeColor: BColors.green,
                                              value: pharmacyProvider
                                                      .productList[index]
                                                      .inStock ??
                                                  false,
                                              onChanged: (value) {
                                                LoadingLottie.showLoading(
                                                    context: context,
                                                    text: 'Please wait');
                                                pharmacyProvider
                                                    .setSelectedProductStock(
                                                        id: pharmacyProvider
                                                            .productList[index]
                                                            .id!)
                                                    .whenComplete(
                                                  () {
                                                    EasyNavigation.pop(
                                                        context: context);
                                                  },
                                                );
                                              },
                                            )))
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
              top: 0,
              right: 0,
              child: PopOverEditDelete(editButton: () {
                if (pharmacyProvider.productList[index].typeOfProduct ==
                    'Medicine') {
                   pharmacyProvider.clearProductDetails();
                  pharmacyProvider.setMedicineEditData(
                      medicineEditData: pharmacyProvider.productList[index]);
                  EasyNavigation.push(
                      type: PageTransitionType.bottomToTop,
                      context: context,
                      page: MedicineAddFormWidget(
                        typeOfProduct:
                            pharmacyProvider.productList[index].typeOfProduct ??
                                'Medicine',
                        isEditing: true,
                        productDetails: pharmacyProvider.productList[index],
                        index: index,
                      ));
                } else if (pharmacyProvider.productList[index].typeOfProduct ==
                    'Equipment') {
                  pharmacyProvider.clearProductDetails();
                  pharmacyProvider.setEquipmentEditData(
                      equipmentEditData: pharmacyProvider.productList[index]);
                  EasyNavigation.push(
                      type: PageTransitionType.bottomToTop,
                      context: context,
                      page: EquipmentAddFormWidget(
                        typeOfProduct:
                            pharmacyProvider.productList[index].typeOfProduct ??
                                'Equipment',
                        isEditing: true,
                        productDetails: pharmacyProvider.productList[index],
                        index: index,
                      ));
                } else {
                     pharmacyProvider.clearProductDetails();
                  pharmacyProvider.setOtherEditData(
                      othersEditData: pharmacyProvider.productList[index]);
                  EasyNavigation.push(
                      type: PageTransitionType.bottomToTop,
                      context: context,
                      page: OtherAddFormWidget(
                        typeOfProduct:
                            pharmacyProvider.productList[index].typeOfProduct ??
                                "Others",
                        isEditing: true,
                        productDetails: pharmacyProvider.productList[index],
                        index: index,
                      ));
                }
              }, deleteButton: () async {
                LoadingLottie.showLoading(
                    context: context, text: "Removing...");

                await pharmacyProvider
                    .deleteProductImageList(
                        imageUrls:
                            pharmacyProvider.productList[index].productImage ??
                                [])
                    .then((value) async {
                  await pharmacyProvider
                      .deletePharmacyProductDetails(
                          index: index,
                          productData: pharmacyProvider.productList[index])
                      .then((value) {
                    EasyNavigation.pop(context: context);
                  });
                });
              }))
        ],
      );
    });
  }
}
