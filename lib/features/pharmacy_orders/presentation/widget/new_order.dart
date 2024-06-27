import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart_pharmacy/core/custom/custom_buttons_and_search/common_button.dart';
import 'package:healthycart_pharmacy/core/custom/lottie/circular_loading.dart';
import 'package:healthycart_pharmacy/core/custom/no_data/no_data_widget.dart';
import 'package:healthycart_pharmacy/core/services/easy_navigation.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/application/provider/request_pharmacy_provider.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/domain/model/product_quantity_model.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/presentation/neworder_details_view_page.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/presentation/prescription_order.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/presentation/widget/product_list_widget.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/presentation/widget/row_text_widget.dart';
import 'package:healthycart_pharmacy/utils/constants/colors/colors.dart';
import 'package:healthycart_pharmacy/utils/constants/image/image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  @override
  void initState() {
    final orderProvider = context.read<RequestPharmacyProvider>();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        orderProvider.getNewOrders();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RequestPharmacyProvider>(
        builder: (context, orderProvider, _) {
      return (orderProvider.fetchloading)
          ? const SliverFillRemaining(
              child: Center(child: LoadingIndicater()),
            )
          : (orderProvider.newOrderList.isEmpty)
              ? const ErrorOrNoDataPage(text: 'No new orders found!')
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList.builder(
                    itemCount: orderProvider.newOrderList.length,
                    itemBuilder: (context, index) {
                      final orderData = orderProvider.newOrderList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: PhysicalModel(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            child: Container(
                              color: Colors.white,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        height: 28,
                                        width: 128,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: BColors.darkblue),
                                        child: Center(
                                          child: Text('Order No-${index + 1}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium!
                                                  .copyWith(
                                                      color: Colors.white)),
                                        ),
                                      ),
                                      Container(
                                        height: 28,
                                        width: 128,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(),
                                            color: BColors.offWhite),
                                        child: Center(
                                          child: Text(
                                              orderProvider.dateFromTimeStamp(
                                                  orderProvider
                                                      .newOrderList[index]
                                                      .createdAt!),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelLarge!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                      color: BColors.darkblue)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(8),
                                  const Divider(),
                                  (orderData.prescription != null &&
                                          (orderData.productDetails!.isEmpty ||
                                              orderData.productDetails == null))
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: BColors.offWhite,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                BImage.prescription,
                                                height: 104,
                                                width: 104,
                                              ),
                                              Text(
                                                'Add products according to the prescription.',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelLarge!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12,
                                                        color: BColors
                                                            .textLightBlack),
                                              ),
                                              const Gap(8),
                                              CustomButton(
                                                  width: double.infinity,
                                                  height: 40,
                                                  onTap: () {
                                                    EasyNavigation.push(
                                                        context: context,
                                                        page:
                                                            PrescriptionOrderDetailsScreen(index: index));
                                                  },
                                                  text: 'View & Add Products',
                                                  buttonColor:
                                                      BColors.mainlightColor,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelLarge!
                                                      .copyWith(
                                                          fontSize: 14,
                                                          color: BColors.white,
                                                          fontWeight:
                                                              FontWeight.w700))
                                            ],
                                          ),
                                        )
                                      : ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return ProductDetailsWidget(
                                              detailsPage: false,
                                              productData: orderData
                                                      .productDetails?[index] ??
                                                  ProductAndQuantityModel(),
                                            );
                                          },
                                          separatorBuilder: (context, index) {
                                            return const Divider();
                                          },
                                          itemCount: (orderData
                                                      .productDetails!.length >
                                                  2)
                                              ? 2
                                              : orderData
                                                  .productDetails!.length),
                                  const Divider(),
                                  (orderData.productDetails!.length > 2)
                                      ? Container(
                                          width: 100,
                                          height: 32,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border.all(),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '+ ${orderData.productDetails!.length - 2}  more',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge!
                                                .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13),
                                          ))
                                      : const SizedBox(),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RowTextContainerWidget(
                                              text1: 'Delivery :',
                                              text2: orderProvider.deliveryType(
                                                  orderData.deliveryType ?? ''),
                                              text1Color:
                                                  BColors.textLightBlack,
                                              fontSizeText1: 12,
                                              fontSizeText2: 12,
                                              fontWeightText1: FontWeight.w600,
                                              text2Color: BColors.black,
                                            ),
                                            (orderData.prescription != null &&
                                                    orderData.prescription!
                                                        .isNotEmpty)
                                                ? const RowTextContainerWidget(
                                                    text1: 'Prescription :',
                                                    text2: 'Included',
                                                    text1Color:
                                                        BColors.textLightBlack,
                                                    fontSizeText1: 12,
                                                    fontSizeText2: 12,
                                                    fontWeightText1:
                                                        FontWeight.w600,
                                                    text2Color: BColors.black,
                                                  )
                                                : const SizedBox(),
                                            RowTextContainerWidget(
                                              text1: 'Total Amount :',
                                              text2:
                                                  "₹ ${orderData.totalAmount}",
                                              text1Color:
                                                  BColors.textLightBlack,
                                              fontSizeText1: 12,
                                              fontSizeText2: 12,
                                              fontWeightText1: FontWeight.w600,
                                              text2Color: BColors.textBlack,
                                            ),
                                            RowTextContainerWidget(
                                              text1: 'Total Discount :',
                                              text2:
                                                  "- ₹ ${orderData.totalAmount! - orderData.totalDiscountAmount!}",
                                              text1Color:
                                                  BColors.textLightBlack,
                                              fontSizeText1: 12,
                                              fontSizeText2: 12,
                                              fontWeightText1: FontWeight.w600,
                                              text2Color: BColors.green,
                                            ),
                                            const Divider(),
                                            RowTextContainerWidget(
                                              text1: 'Amount To Be Paid :',
                                              text2:
                                                  "₹ ${orderData.totalDiscountAmount}",
                                              text1Color: BColors.textBlack,
                                              fontSizeText1: 13,
                                              fontSizeText2: 13,
                                              fontWeightText1: FontWeight.w600,
                                              text2Color: BColors.green,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Ordered by',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                orderData.userDetails
                                                        ?.userName ??
                                                    'Unknown user',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelLarge!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600),
                                              ),
                                              Row(
                                                children: [
                                                  PhysicalModel(
                                                    elevation: 2,
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    child: SizedBox(
                                                      width: 40,
                                                      height: 40,
                                                      child: Center(
                                                        child: IconButton(
                                                            onPressed: () {},
                                                            icon: const Icon(
                                                              Icons
                                                                  .location_on_sharp,
                                                              size: 24,
                                                              color:
                                                                  Colors.blue,
                                                            )),
                                                      ),
                                                    ),
                                                  ),
                                                  const Gap(12),
                                                  PhysicalModel(
                                                    elevation: 2,
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    child: SizedBox(
                                                      width: 40,
                                                      height: 40,
                                                      child: Center(
                                                        child: IconButton(
                                                          onPressed: () {
                                                            orderProvider.lauchDialer(
                                                                phoneNumber: orderData
                                                                        .userDetails
                                                                        ?.phoneNo ??
                                                                    '');
                                                          },
                                                          icon: const Icon(
                                                              Icons.phone,
                                                              size: 24,
                                                              color:
                                                                  Colors.blue),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Gap(8),
                                  (orderData.productDetails!.isNotEmpty &&
                                          orderData.productDetails != null)
                                      ? Column(
                                          children: [
                                            SizedBox(
                                              height: 40,
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  EasyNavigation.push(
                                                    type: PageTransitionType
                                                        .rightToLeft,
                                                    context: context,
                                                    page: OrderDetailsScreen(
                                                      index: index,
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      BColors.mainlightColor,
                                                  surfaceTintColor:
                                                      Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                ),
                                                child: Text('View Full Order',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelLarge!
                                                        .copyWith(
                                                            fontSize: 14,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700)),
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox()
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
    });
  }
}
