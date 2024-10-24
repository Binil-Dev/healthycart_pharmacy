import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart_pharmacy/core/custom/custom_cached_network/custom_cached_network_image.dart';
import 'package:healthycart_pharmacy/core/custom/lottie/circular_loading.dart';
import 'package:healthycart_pharmacy/core/custom/no_data/no_data_widget.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/application/provider/request_pharmacy_provider.dart';
import 'package:healthycart_pharmacy/utils/constants/colors/colors.dart';
import 'package:healthycart_pharmacy/utils/constants/image/image.dart';

import 'package:provider/provider.dart';

class UserPayment extends StatefulWidget {
  const UserPayment({super.key});

  @override
  State<UserPayment> createState() => _UserPaymentState();
}

class _UserPaymentState extends State<UserPayment> {
  final _scrollcontroller = ScrollController();
  @override
  void initState() {
    final orderProvider = context.read<RequestPharmacyProvider>();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        orderProvider
          ..clearCompletedOrderFetchData()
          ..getCompletedOrderDetails(limit: 15);
      },
    );
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
    final ordersProvider = Provider.of<RequestPharmacyProvider>(context);

    return Scaffold(
        body: CustomScrollView(
      controller: _scrollcontroller,
      slivers: [
        if (ordersProvider.fetchloading == true &&
            ordersProvider.completedOrderList.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: LoadingIndicater(),
            ),
          )
        else if (ordersProvider.completedOrderList.isEmpty)
          const SliverFillRemaining(
            child: NoDataImageWidget(text: 'No Transactiond Found!'),
          )
        else
          SliverPadding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 32),
            sliver: SliverList.separated(
              separatorBuilder: (context, index) => const Gap(5),
              itemCount: ordersProvider.completedOrderList.length,
              itemBuilder: (context, index) {
                final orders = ordersProvider.completedOrderList[index];
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all()),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          clipBehavior: Clip.antiAlias,
                          height: 50,
                          width: 50,
                          decoration:
                              const BoxDecoration(shape: BoxShape.circle),
                          child: orders.userDetails!.image == null
                              ? Image.asset(BImage.userAvatar)
                              : CustomCachedNetworkImage(
                                  image: orders.userDetails!.image!),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                          orders.userDetails!.userName ??
                                              'Not Provided',
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge!
                                              .copyWith(fontSize: 12)),
                                    ),
                                    Text(
                                      orders.paymentType ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(
                                              color: BColors.green,
                                              fontSize: 12),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            '₹${orders.finalAmount ?? 0}',
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge!
                                                .copyWith(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Commission : ${orders.commission}%',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .copyWith(fontSize: 12)),
                                    Text(
                                        'Commission Amt : ₹${orders.commissionAmt}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .copyWith(fontSize: 12)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        SliverToBoxAdapter(
            child: (ordersProvider.fetchloading == true &&
                    ordersProvider.completedOrderList.isNotEmpty)
                ? const Center(child: LoadingIndicater())
                : const Gap(0)),
      ],
    ),
          bottomNavigationBar: ordersProvider.pharmacyTransactionModel != null
          ? Container(
              height: 52,
              color: BColors.mainlightColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Transaction : ₹${ordersProvider.pharmacyTransactionModel!.totalTransactionAmt}',
                      style: const TextStyle(
                          color: BColors.darkblue, fontSize: 12),
                    ),
                    Text(
                      'Total Commission : ₹${ordersProvider.pharmacyTransactionModel!.totalCommissionPending}',
                      style: const TextStyle(
                          color: BColors.darkblue, fontSize: 12),
                    )
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
