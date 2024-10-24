import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart_pharmacy/core/custom/custom_buttons_and_search/common_button.dart';
import 'package:healthycart_pharmacy/core/custom/custom_buttons_and_search/search_field_button.dart';
import 'package:healthycart_pharmacy/core/custom/lottie/circular_loading.dart';
import 'package:healthycart_pharmacy/core/custom/lottie/loading_lottie.dart';
import 'package:healthycart_pharmacy/core/custom/no_data/no_data_widget.dart';
import 'package:healthycart_pharmacy/core/custom/toast/toast.dart';
import 'package:healthycart_pharmacy/core/services/easy_navigation.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/application/provider/request_pharmacy_provider.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/domain/model/user_model.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/presentation/widget/address_card.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/presentation/widget/checkbox_order.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/presentation/widget/date_and_order_id.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/presentation/widget/details_onprocess.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/presentation/widget/quantity_container.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/presentation/widget/row_text_widget.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/presentation/widget/user_detail_container.dart';
import 'package:healthycart_pharmacy/utils/constants/colors/colors.dart';
import 'package:provider/provider.dart';

class OnProcessOrderScreen extends StatefulWidget {
  const OnProcessOrderScreen({super.key});
  @override
  State<OnProcessOrderScreen> createState() => _OnProcessOrderScreenState();
}

class _OnProcessOrderScreenState extends State<OnProcessOrderScreen> {
  @override
  void initState() {
    final orderProvider = context.read<RequestPharmacyProvider>();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        orderProvider.cancelStream();
        orderProvider.getTransactionData();
        orderProvider.getpharmacyOnProcessData();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RequestPharmacyProvider>(
            builder: (context, orderProvider, _) {
        return SliverFillRemaining(
          child: CustomScrollView(
            slivers: [
                   SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SearchTextFieldButton(
                    onSubmit: (value) {
                      orderProvider.getpharmacyOnProcessData(searchPhoneNumber: value);
                    },
                    text: 'Search on process order by phone number',
                    controller: orderProvider.searchAcceptedBookingsController),
              ),
            ),
                 (orderProvider.fetchloading)
                    ? const SliverFillRemaining(
                        child: Center(child: LoadingIndicater()),
                      )
                    : (orderProvider.onProcessOrderList.isEmpty &&
                            !orderProvider.fetchloading)
                        ? const ErrorOrNoDataPage(text: 'No on process orders found!')
                        : SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverList.builder(
                              itemCount: orderProvider.onProcessOrderList.length,
                              itemBuilder: (context, index) {
                                final onProcessOrderData =
                                    orderProvider.onProcessOrderList[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.grey,
                                          blurRadius: 6.0,
                                        ),
                                      ],
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          OrderIDAndDateSection(
                                            orderData: onProcessOrderData,
                                            date: orderProvider.dateFromTimeStamp(
                                                onProcessOrderData.acceptedAt!),
                                          ),
                                          const Gap(8),
                                          Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(),
                                                borderRadius: BorderRadius.circular(8)),
                                            child: Column(
                                              children: [
                                                ListView.builder(
                                                  padding: const EdgeInsets.only(
                                                    left: 6,
                                                    right: 8,
                                                    top: 8,
                                                  ),
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount: onProcessOrderData
                                                      .productDetails?.length,
                                                  itemBuilder: (context, index) {
                                                    return Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.center,
                                                          children: [
                                                            Flexible(
                                                              flex: 2,
                                                              child: Text(
                                                                  onProcessOrderData
                                                                          .productDetails?[
                                                                              index]
                                                                          .productData
                                                                          ?.productName ??
                                                                      'Unknown Product',
                                                                  overflow: TextOverflow
                                                                      .ellipsis,
                                                                  style: Theme.of(context)
                                                                      .textTheme
                                                                      .labelMedium!
                                                                      .copyWith(
                                                                          color: BColors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .w500,
                                                                          fontSize: 12)),
                                                            ),
                                                            Flexible(
                                                              flex: 1,
                                                              child: QuantitiyBox(
                                                                productQuantity:
                                                                    '${onProcessOrderData.productDetails?[index].quantity ?? '0'}',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const Gap(6),
                                                      ],
                                                    );
                                                  },
                                                ),
                                                CustomButton(
                                                  width: 184,
                                                  height: 32,
                                                  onTap: () {
                                                    EasyNavigation.push(
                                                        context: context,
                                                        page: DetailsOnProcessScreen(
                                                          data: onProcessOrderData,
                                                        ));
                                                  },
                                                  text: 'View items details',
                                                  buttonColor: BColors.mainlightColor,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelLarge!
                                                      .copyWith(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w700),
                                                ),
                                                const Gap(8)
                                              ],
                                            ),
                                          ),
                                          const Divider(),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                RowTextContainerWidget(
                                                  text1: 'Delivery : ',
                                                  text2: orderProvider.deliveryType(
                                                      onProcessOrderData.deliveryType ??
                                                          ''),
                                                  text1Color: BColors.textLightBlack,
                                                  fontSizeText1: 12,
                                                  fontSizeText2: 12,
                                                  fontWeightText1: FontWeight.w600,
                                                  text2Color: BColors.green,
                                                ),
                                                const Gap(4),
                                                RowTextContainerWidget(
                                                  text1: 'User Status : ',
                                                  text2: (onProcessOrderData
                                                              .isUserAccepted !=
                                                          true)
                                                      ? 'Pending'
                                                      : 'Approved',
                                                  text1Color: BColors.textLightBlack,
                                                  fontSizeText1: 12,
                                                  fontSizeText2: 12,
                                                  fontWeightText1: FontWeight.w600,
                                                  text2Color: (onProcessOrderData
                                                              .isUserAccepted !=
                                                          true)
                                                      ? Colors.amber
                                                      : BColors.green,
                                                ),
                                                const Gap(4),
                                                RowTextContainerWidget(
                                                  text1: 'Payment Mode : ',
                                                  text2: orderProvider.paymentType(
                                                      onProcessOrderData.paymentType ??
                                                          ''),
                                                  text1Color: BColors.textLightBlack,
                                                  fontSizeText1: 12,
                                                  fontSizeText2: 12,
                                                  fontWeightText1: FontWeight.w600,
                                                  text2Color:
                                                      (onProcessOrderData.paymentType ==
                                                                  null ||
                                                              onProcessOrderData
                                                                  .paymentType!.isEmpty)
                                                          ? Colors.amber
                                                          : BColors.green,
                                                ),
                                                const Gap(4),
                                                RowTextContainerWidget(
                                                  text1: 'Payment Status : ',
                                                  text2:
                                                      (onProcessOrderData.paymentStatus ==
                                                              0)
                                                          ? 'Pending'
                                                          : 'Completed',
                                                  text1Color: BColors.textLightBlack,
                                                  fontSizeText1: 12,
                                                  fontSizeText2: 12,
                                                  fontWeightText1: FontWeight.w600,
                                                  text2Color:
                                                      (onProcessOrderData.paymentStatus ==
                                                              0)
                                                          ? Colors.amber
                                                          : BColors.green,
                                                ),
                                                if (onProcessOrderData.paymentType ==
                                                    'COD')
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        'Payment Recieved ?',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .labelLarge!
                                                            .copyWith(
                                                                decoration: TextDecoration
                                                                    .underline,
                                                                color: BColors
                                                                    .textLightBlack,
                                                                fontWeight:
                                                                    FontWeight.w600,
                                                                fontSize: 11),
                                                      ),
                                                      Checkbox(
                                                        value: onProcessOrderData
                                                                .isPaymentRecieved ??
                                                            false,
                                                        onChanged: (value) {
                                                          LoadingLottie.showLoading(
                                                              context: context,
                                                              text: 'Please wait...');
                                                          orderProvider
                                                              .updateOrderStatusToDeliverDetails(
                                                                  productData:
                                                                      onProcessOrderData,
                                                                  value: 3,
                                                                  updateValue: value!)
                                                              .whenComplete(
                                                            () {
                                                              EasyNavigation.pop(
                                                                  context: context);
                                                            },
                                                          );
                                                        },
                                                        activeColor: BColors.offRed,
                                                      ),
                                                    ],
                                                  ),
                                                const Divider(),
                                                RowTextContainerWidget(
                                                  text1: 'Total Amount : ',
                                                  text2:
                                                      '₹ ${onProcessOrderData.finalAmount}',
                                                  text1Color: BColors.textLightBlack,
                                                  fontSizeText1: 13,
                                                  fontSizeText2: 14,
                                                  fontWeightText1: FontWeight.w600,
                                                  text2Color: BColors.green,
                                                ),
                                                const Gap(4),
                                                Align(
                                                  alignment: Alignment.bottomRight,
                                                  child: Text(
                                                    'All charges included.',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelLarge!
                                                        .copyWith(
                                                            fontSize: 10,
                                                            color: BColors.textLightBlack,
                                                            fontWeight: FontWeight.w500),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          const Divider(),
                                          (onProcessOrderData.isUserAccepted == true)
                                              ? Wrap(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        OrderCheckBox(
                                                            text: 'Processing',
                                                            onChanged: (value) {},
                                                            value: onProcessOrderData
                                                                    .isUserAccepted ??
                                                                false),
                                                        OrderCheckBox(
                                                          text: 'Packed',
                                                          onChanged: (value) {
                                                            if (onProcessOrderData
                                                                    .isOrderDelivered ==
                                                                true) {
                                                              CustomToast.sucessToast(
                                                                  text:
                                                                      'The order delivery is completed.');
                                                              return;
                                                            }
                                                            LoadingLottie.showLoading(
                                                                context: context,
                                                                text: 'Please wait...');
                                                            orderProvider
                                                                .updateOrderStatusToDeliverDetails(
                                                                    productData:
                                                                        onProcessOrderData,
                                                                    value: 1,
                                                                    updateValue: value!)
                                                                .whenComplete(
                                                              () {
                                                                EasyNavigation.pop(
                                                                    context: context);
                                                              },
                                                            );
                                                          },
                                                          value: onProcessOrderData
                                                                  .isOrderPacked ??
                                                              false,
                                                        ),
                                                        OrderCheckBox(
                                                            text: 'Delivered',
                                                            onChanged: (value) {
                                                              if (!onProcessOrderData
                                                                  .isOrderPacked!) {
                                                                CustomToast.errorToast(
                                                                    text:
                                                                        'Complete packing to deliver the product.');
                                                                return;
                                                              }
                                                              LoadingLottie.showLoading(
                                                                  context: context,
                                                                  text: 'Please wait...');
                                                              orderProvider
                                                                  .updateOrderStatusToDeliverDetails(
                                                                      productData:
                                                                          onProcessOrderData,
                                                                      value: 2,
                                                                      updateValue: value!)
                                                                  .whenComplete(
                                                                () {
                                                                  EasyNavigation.pop(
                                                                      context: context);
                                                                },
                                                              );
                                                            },
                                                            value: onProcessOrderData
                                                                    .isOrderDelivered ??
                                                                false),
                                                      ],
                                                    ),
                                                  ],
                                                )
                                              : Text(
                                                  'Order is in customer review !',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelLarge!
                                                      .copyWith(
                                                          color: BColors.offRed,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 14),
                                                ),
                                          Column(
                                            children: [
                                              const Divider(),
                                              (onProcessOrderData.addresss != null &&
                                                      onProcessOrderData.deliveryType ==
                                                          "Home")
                                                  ? Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Delivery Address : ',
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .labelLarge!
                                                              .copyWith(
                                                                  color: BColors
                                                                      .textLightBlack,
                                                                  fontWeight:
                                                                      FontWeight.w600,
                                                                  fontSize: 12),
                                                        ),
                                                        const Gap(8),
                                                        Expanded(
                                                          child: AddressCard(
                                                              addressData:
                                                                  onProcessOrderData
                                                                      .addresss!),
                                                        ),
                                                      ],
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Pick-Up Address : ',
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .labelLarge!
                                                              .copyWith(
                                                                  color: BColors
                                                                      .textLightBlack,
                                                                  fontWeight:
                                                                      FontWeight.w600,
                                                                  fontSize: 12),
                                                        ),
                                                        const Gap(8),
                                                        Expanded(
                                                          child: Text(
                                                            '${onProcessOrderData.pharmacyDetails?.pharmacyName ?? 'Pharmacy'}-${onProcessOrderData.pharmacyDetails?.pharmacyAddress ?? 'Pharmacy'}',
                                                            maxLines: 3,
                                                            overflow:
                                                                TextOverflow.ellipsis,
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .labelLarge!
                                                                .copyWith(
                                                                    color:
                                                                        BColors.textBlack,
                                                                    fontWeight:
                                                                        FontWeight.w600,
                                                                    fontSize: 12),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                              const Divider(),
                                            ],
                                          ),
                                          UserDetailsContainer(
                                            userData: onProcessOrderData.userDetails ??
                                                UserModel(),
                                          ),
                                          const Gap(16),
                                          if (onProcessOrderData.isUserAccepted == true &&
                                              onProcessOrderData.paymentStatus != 0 &&
                                              onProcessOrderData.isOrderPacked == true &&
                                              onProcessOrderData.isPaymentRecieved ==
                                                  true &&
                                              onProcessOrderData.isOrderDelivered == true)
                                            CustomButton(
                                              width: double.infinity,
                                              height: 40,
                                              onTap: () {
                                                if (onProcessOrderData.isUserAccepted !=
                                                    true) {
                                                  CustomToast.errorToast(
                                                      text:
                                                          'Order is not accepted by user.');
                                                  return;
                                                }
                                                if (onProcessOrderData.paymentStatus ==
                                                    0) {
                                                  CustomToast.errorToast(
                                                      text: 'Payment is not done yet.');
                                                  return;
                                                }
                                                LoadingLottie.showLoading(
                                                    context: context,
                                                    text: 'Please wait...');
                                                orderProvider
                                                    .updateOrderCompletedDetails(
                                                  productData: onProcessOrderData,
                                                  context: context,
                                                  commission: orderProvider
                                                      .pharmacyTransactionModel!
                                                      .commission,
                                                  commissionAmt: orderProvider
                                                      .calculateOrderCommission(
                                                          onProcessOrderData
                                                              .finalAmount!),
                                                )
                                                    .whenComplete(
                                                  () {
                                                    EasyNavigation.pop(context: context);
                                                  },
                                                );
                                              },
                                              text: 'Complete Order',
                                              buttonColor: BColors.green,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium!
                                                  .copyWith(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w700),
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
             
            ],
          ),
        );
      }
    );
  }
}
