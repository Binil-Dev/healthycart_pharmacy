import 'package:flutter/material.dart';
import 'package:healthycart_pharmacy/core/custom/custom_alertbox/confirm_alertbox_widget.dart';
import 'package:healthycart_pharmacy/core/custom/custom_cached_network/custom_cached_network_image.dart';
import 'package:healthycart_pharmacy/core/custom/toast/toast.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/application/provider/request_pharmacy_provider.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/domain/model/product_quantity_model.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/presentation/widget/quantity_container.dart';
import 'package:healthycart_pharmacy/utils/constants/colors/colors.dart';
import 'package:healthycart_pharmacy/utils/constants/image/image.dart';
import 'package:provider/provider.dart';

class ProductDetailsWidget extends StatelessWidget {
  const ProductDetailsWidget({
    super.key,
    required this.detailsPage,
    required this.productData,
    this.index,
  });
  final bool detailsPage;
  final ProductAndQuantityModel productData;
  final int? index;
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<RequestPharmacyProvider>(context);
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(56),
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(56),
                  child: (productData.productData?.productImage != null)
                            ? CustomCachedNetworkImage(
                                image: productData.productData?.productImage?.first ??
                                    '',
                                fit: BoxFit.contain,
                              )
                            : Image.asset(BImage.roundLogo)),
            ),
            Flexible(
              flex: 4,
              fit: FlexFit.tight,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productData.productData?.productName ?? 'Unknown Name',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(children: [
                        TextSpan(
                          text: 'by ', // remeber to put space
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(
                                  fontWeight: FontWeight.w600, fontSize: 11,),
                        ),
                        TextSpan(
                            text: productData.productData?.productBrandName ??
                                'Unkown Brand',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  color: BColors.textBlack,
                                )),
                      ]),
                    ),
                    (productData.productData?.productDiscountRate == null)
                        ? RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: 'Price : ',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11),
                              ),
                              TextSpan(
                                text: "₹ ",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: BColors.green),
                              ),
                              TextSpan(
                                text:
                                    '${productData.productData?.productMRPRate}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: BColors.green),
                              ),
                            ]),
                          )
                        : RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: 'Price : ',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11),
                              ),
                              TextSpan(
                                  text: "₹ ",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Montserrat',
                                      color: BColors.green)),
                              TextSpan(
                                text:
                                    '${productData.productData?.productDiscountRate}',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Montserrat',
                                    color: BColors.green),
                              ),
                              const TextSpan(text: '  '),
                              TextSpan(
                                  text: "₹ ",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                          color: BColors.textBlack)),
                              TextSpan(
                                text:
                                    '${productData.productData?.productMRPRate}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .copyWith(
                                        decoration: TextDecoration.lineThrough,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                        color: BColors.textBlack),
                              ),
                            ]),
                          ),
                    RichText(
                      text: TextSpan(
                        children: [
                        TextSpan(
                          text: (productData.productData?.productFormNumber != null)
                              ? '${productData.productData?.productFormNumber} '
                              : '',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: BColors.textBlack,
                                  fontSize: 11),
                        ),
                        TextSpan(
                          text: (productData.productData?.productForm != null)
                              ? '${productData.productData?.productForm}, '
                              : '',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: BColors.textBlack,
                                  fontSize: 11),
                        ),
                        TextSpan(
                          text: (productData.productData?.productPackageNumber != null)
                              ? '${productData.productData?.productPackageNumber} ' : '',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: BColors.textBlack,
                                  fontSize: 11),
                        ),
                        TextSpan(
                          text: (productData.productData?.productPackage != null)
                              ? '${productData.productData?.productPackage}, '
                              : '',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: BColors.textBlack,
                                  fontSize: 11),
                        ),
                        TextSpan(
                          text: (productData
                                      .productData?.productMeasurementNumber !=
                                  null)
                              ? '${productData.productData?.productMeasurementNumber} '
                              : '',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: BColors.textBlack,
                                  fontSize: 11),
                        ),
                        TextSpan(
                          text: (productData.productData?.productMeasurement !=
                                  null)
                              ? '${productData.productData?.productMeasurement} '
                              : '',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: BColors.textBlack,
                                  fontSize: 11),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
                flex: detailsPage ? 2 : 1,
                fit: FlexFit.loose,
                child: QuantitiyBox(
                  productQuantity: '${productData.quantity}',
                ))
          ],
        ),
        if (detailsPage)
          Positioned(
              top: -12,
              right: -5,
              child: IconButton(
                  onPressed: () {
                    ConfirmAlertBoxWidget.showAlertConfirmBox(
                        context: context,
                        confirmButtonTap: () {
                          if (orderProvider.pharmacyUserProducts.length <= 1) {
                            CustomToast.errorToast(
                                text:
                                    "Can't remove the item, since only one item is present.");
                            return;
                          }
                          orderProvider.removeProduct(index: index!); 
                          orderProvider.removePrescriptionProduct(
                              id: productData.productId ?? '');// here when removing from the prescription detail page we are also removing from the map
                        },
                        titleText: 'Remove this item',
                        subText: 'Are you sure you want to proceed ?');
                  },
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: BColors.red,
                    size: 28,
                  )))
      ],
    );
  }
}
