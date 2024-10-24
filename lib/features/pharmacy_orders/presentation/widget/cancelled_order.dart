import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart_pharmacy/core/custom/custom_buttons_and_search/search_field_button.dart';
import 'package:healthycart_pharmacy/core/custom/lottie/circular_loading.dart';
import 'package:healthycart_pharmacy/core/custom/no_data/no_data_widget.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/application/provider/request_pharmacy_provider.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/domain/model/user_model.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/presentation/widget/date_and_order_id.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/presentation/widget/product_view_container.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/presentation/widget/row_text_widget.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/presentation/widget/user_detail_container.dart';
import 'package:healthycart_pharmacy/utils/constants/colors/colors.dart';
import 'package:provider/provider.dart';

class CancelledOrderScreen extends StatefulWidget {
  const CancelledOrderScreen({super.key});

  @override
  State<CancelledOrderScreen> createState() => _CancelledOrderScreenState();
}

class _CancelledOrderScreenState extends State<CancelledOrderScreen> {
  final ScrollController _scrollcontroller = ScrollController();
  @override
  void initState() {
    final orderProvider = context.read<RequestPharmacyProvider>();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) {
      orderProvider.clearCancelledOrderFetchData();
      orderProvider.getCancelledOrderDetails();
    });

    _scrollcontroller.addListener(() {
      if (_scrollcontroller.position.atEdge &&
          _scrollcontroller.position.pixels != 0 &&
          orderProvider.fetchloading == false) {
        orderProvider.getCancelledOrderDetails();
      }
    });

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
                      orderProvider.searchCancelledOrders();
                    },
                    text: 'Search cancelled order by phone number',
                    controller:
                        orderProvider.searchCancelledOrdersController),
              ),
            ),
            (orderProvider.fetchloading)
                ? const SliverFillRemaining(
                    child: Center(child: LoadingIndicater()),
                  )
                : (orderProvider.cancelledOrderList.isEmpty &&
                        !orderProvider.fetchloading)
                    ? const ErrorOrNoDataPage(
                        text: 'No cancelled orders found!')
                    : SliverFillRemaining(
                        child: CustomScrollView(
                          controller: _scrollcontroller,
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.all(16),
                              sliver: SliverList.builder(
                                itemCount:
                                    orderProvider.cancelledOrderList.length,
                                itemBuilder: (context, index) {
                                  final cancelledOrderData =
                                      orderProvider.cancelledOrderList[index];
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            OrderIDAndDateSection(
                                              orderData: cancelledOrderData,
                                              date: orderProvider
                                                  .dateFromTimeStamp(
                                                      cancelledOrderData
                                                              .rejectedAt ??
                                                          Timestamp.now()),
                                            ),
                                            const Gap(8),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.cancel_rounded,
                                                  color: BColors.offRed,
                                                  size: 40,
                                                ),
                                                const Gap(8),
                                                Text(
                                                  'Order Cancelled !',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium!
                                                      .copyWith(
                                                          color: BColors.offRed,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 16),
                                                ),
                                              ],
                                            ),
                                            const Gap(8),
                                            if (cancelledOrderData
                                                .productDetails!.isNotEmpty)
                                              ProductShowContainer(
                                                  orderData:
                                                      cancelledOrderData),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (cancelledOrderData
                                                      .productDetails!
                                                      .isNotEmpty)
                                                    RowTextContainerWidget(
                                                      text1: 'Total Amount : ',
                                                      text2:
                                                          '₹ ${cancelledOrderData.finalAmount}',
                                                      text1Color: BColors
                                                          .textLightBlack,
                                                      fontSizeText1: 13,
                                                      fontSizeText2: 13,
                                                      fontWeightText1:
                                                          FontWeight.w600,
                                                      text2Color: BColors.green,
                                                    ),
                                                  const Divider(),
                                                  RowTextContainerWidget(
                                                    text1: 'Rejected by : ',
                                                    text2: (cancelledOrderData
                                                                .isRejectedByUser ==
                                                            true)
                                                        ? 'Customer'
                                                        : 'Pharmacy',
                                                    text1Color:
                                                        BColors.textLightBlack,
                                                    fontSizeText1: 12,
                                                    fontSizeText2: 13,
                                                    fontWeightText1:
                                                        FontWeight.w600,
                                                    text2Color: BColors.red,
                                                  ),
                                                  const Gap(6),
                                                  (cancelledOrderData
                                                                  .rejectReason ==
                                                              null ||
                                                          cancelledOrderData
                                                              .rejectReason!
                                                              .isEmpty)
                                                      ? const SizedBox()
                                                      : Container(
                                                          width:
                                                              double.infinity,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: BColors
                                                                      .mainlightColor),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8)),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Rejection reason :',
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .labelMedium!
                                                                    .copyWith(
                                                                        color: BColors
                                                                            .textLightBlack,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        fontSize:
                                                                            12),
                                                              ),
                                                              const Gap(6),
                                                              Text(
                                                                cancelledOrderData
                                                                        .rejectReason ??
                                                                    'Unknown reason',
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .labelMedium!
                                                                    .copyWith(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontSize:
                                                                            12),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                  const Divider(),
                                                  UserDetailsContainer(
                                                    userData: cancelledOrderData
                                                            .userDetails ??
                                                        UserModel(),
                                                  ),
                                                  const Gap(16),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
          ],
        ),
      );
    });
  }
}
