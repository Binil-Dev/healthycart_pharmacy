// ignore_for_file: use_build_context_synchronously
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart_pharmacy/core/custom/custom_buttons_and_search/search_field_button.dart';
import 'package:healthycart_pharmacy/core/custom/lottie/circular_loading.dart';
import 'package:healthycart_pharmacy/core/custom/no_data/no_data_widget.dart';
import 'package:healthycart_pharmacy/core/services/easy_navigation.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/application/pharmacy_provider.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/presentation/pharmacy_product/widgets/bottomsheet_product_choose.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/presentation/pharmacy_product/widgets/list_product_view.dart';
import 'package:healthycart_pharmacy/utils/constants/colors/colors.dart';
import 'package:provider/provider.dart';

import '../../../../core/custom/app_bar/sliver_appbar.dart';

class PharmacyProductScreen extends StatefulWidget {
  const PharmacyProductScreen({super.key});

  @override
  State<PharmacyProductScreen> createState() => _PharmacyProductScreenState();
}

class _PharmacyProductScreenState extends State<PharmacyProductScreen> {
  final ScrollController _scrollcontroller = ScrollController();
  @override
  void initState() {
    final pharmacyProvider = context.read<PharmacyProvider>();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) {
      pharmacyProvider.getproductFormAndPackageList();
      pharmacyProvider.clearFetchData();
      pharmacyProvider.getPharmacyProductDetails();
    });

    _scrollcontroller.addListener(() {
      if (_scrollcontroller.position.atEdge &&
          _scrollcontroller.position.pixels != 0 &&
          pharmacyProvider.fetchLoading == false) {
        pharmacyProvider.getPharmacyProductDetails();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    EasyDebounce.cancel('searchproduct');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Consumer<PharmacyProvider>(builder: (context, pharmacyProvider, _) {
        return Scaffold(
          body:  PopScope(
              onPopInvoked: (didPop) {
                pharmacyProvider.clearPackageAndFormDetails();
              },
              child: CustomScrollView(
                controller: _scrollcontroller,
                slivers: [
                  SliverCustomAppbar(
                    title: pharmacyProvider.selectedCategoryText ?? 'Product List',
                    onBackTap: () {
                      EasyNavigation.pop(context: context);
                    },
                    child: PreferredSize(
                      preferredSize: const Size(double.infinity, 68),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 8, top: 4),
                        child: SearchTextFieldButton(
                          text: "Search products...",
                          controller: pharmacyProvider.searchController,
                          onChanged: (value) {
                            EasyDebounce.debounce(
                                'searchproduct', const Duration(milliseconds: 500),
                                () {
                              pharmacyProvider.searchProduct(value);
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 16, bottom: 8, left: 16, right: 16),
                      child: Text(
                        "Products List",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  (pharmacyProvider.fetchLoading &&
                          pharmacyProvider.productList.isEmpty)
        
                      /// loading is done here
                      ? const SliverFillRemaining(
                          child: Center(
                            child: LoadingIndicater(),
                          ),
                        )
                      : (pharmacyProvider.productList.isEmpty)
                          ? const ErrorOrNoDataPage(
                              text: "No Products added in this category.",
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              sliver: SliverList.builder(
                                itemCount: pharmacyProvider.productList.length,
                                itemBuilder: (context, index) {
                                  return ProductListWidget(
                                    index: index,
                                  );
                                },
                              ),
                            ),
                  const SliverGap(80),
                  SliverToBoxAdapter(
                      child: (pharmacyProvider.fetchLoading == true &&
                              pharmacyProvider.productList.isNotEmpty)
                          ? const Center(child: LoadingIndicater())
                          : null),
                ],
              ),
            ),
          
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(
              bottom: 48,
            ),
            child: SizedBox(
              width: 136,
              child: FloatingActionButton(
                elevation: 10,
                tooltip: 'Add new product',
                clipBehavior: Clip.antiAlias,
                isExtended: true,
                backgroundColor: BColors.darkblue,
                onPressed: () {
                  showModalBottomSheet(
                      showDragHandle: true,
                      elevation: 10,
                      backgroundColor: Colors.white,
                      context: context,
                      builder: (context) {
                        return const ChooseProductBottomSheet();
                      });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: Text('Add New',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(fontSize: 14, color: BColors.white)),
                      ),
                      const Gap(4),
                      const Icon(
                        Icons.assignment_add,
                        color: BColors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}
