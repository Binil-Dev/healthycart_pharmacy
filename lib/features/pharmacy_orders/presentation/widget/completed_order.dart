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

class CompletedOrderScreen extends StatefulWidget {
  const CompletedOrderScreen({super.key});

  @override
  State<CompletedOrderScreen> createState() => _CompletedOrderScreenState();
}

class _CompletedOrderScreenState extends State<CompletedOrderScreen> {
  final ScrollController _scrollcontroller = ScrollController();
  @override
  void initState() {
    final orderProvider = context.read<RequestPharmacyProvider>();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) {
      orderProvider.clearCompletedOrderFetchData();
      orderProvider.getCompletedOrderDetails(limit: 5);
    });

    _scrollcontroller.addListener(() {
      if (_scrollcontroller.position.atEdge &&
          _scrollcontroller.position.pixels != 0 &&
          orderProvider.fetchloading == false) {
        orderProvider.getCompletedOrderDetails(limit: 5);
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
                      orderProvider.searchCompletedOrders();
                    },
                    text: 'Search completed order by phone number',
                    controller:
                        orderProvider.searchCompletedBookingsController),
              ),
            ),
            (orderProvider.fetchloading)
                ? const SliverFillRemaining(
                    child: Center(child: LoadingIndicater()),
                  )
                : (orderProvider.completedOrderList.isEmpty &&
                        !orderProvider.fetchloading)
                    ? const ErrorOrNoDataPage(
                        text: 'No completed orders found!')
                    : SliverFillRemaining(
                        child: CustomScrollView(
                          controller: _scrollcontroller,
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.all(16),
                              sliver: SliverList.builder(
                                itemCount:
                                    orderProvider.completedOrderList.length,
                                itemBuilder: (context, index) {
                                  final completedOrderData =
                                      orderProvider.completedOrderList[index];
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
                                              orderData: completedOrderData,
                                              date: orderProvider
                                                  .dateFromTimeStamp(
                                                      completedOrderData
                                                              .completedAt ??
                                                          Timestamp.now()),
                                            ),
                                            const Gap(8),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.task_alt_rounded,
                                                  color: BColors.green,
                                                  size: 40,
                                                ),
                                                const Gap(8),
                                                Text('Order Completed !',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium!
                                                        .copyWith(
                                                            color:
                                                                BColors.green,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 16)),
                                              ],
                                            ),
                                            const Gap(8),
                                            ProductShowContainer(
                                                orderData: completedOrderData),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Divider(),
                                                  RowTextContainerWidget(
                                                    text1: 'Total Amount : ',
                                                    text2:
                                                        '₹ ${completedOrderData.finalAmount}',
                                                    text1Color:
                                                        BColors.textLightBlack,
                                                    fontSizeText1: 13,
                                                    fontSizeText2: 13,
                                                    fontWeightText1:
                                                        FontWeight.w600,
                                                    text2Color: BColors.green,
                                                  ),
                                                  const Divider(),
                                                  UserDetailsContainer(
                                                    userData: completedOrderData
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
