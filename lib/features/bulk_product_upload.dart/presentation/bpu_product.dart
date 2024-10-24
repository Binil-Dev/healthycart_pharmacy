import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart_pharmacy/core/custom/app_bar/sliver_appbar.dart';
import 'package:healthycart_pharmacy/core/custom/custom_buttons_and_search/common_button.dart';
import 'package:healthycart_pharmacy/core/custom/lottie/loading_lottie.dart';
import 'package:healthycart_pharmacy/features/bulk_product_upload.dart/application/bpu_provider.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/presentation/pharmacy_product/widgets/dropdown_button.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/presentation/pharmacy_product/widgets/product_choose_button_widget.dart';
import 'package:healthycart_pharmacy/utils/constants/colors/colors.dart';
import 'package:provider/provider.dart';

class BPUProductScreen extends StatefulWidget {
  const BPUProductScreen({super.key});

  @override
  State<BPUProductScreen> createState() => _BPUProductScreenState();
}

class _BPUProductScreenState extends State<BPUProductScreen> {
  @override
  void initState() {
    final bpuProvider = Provider.of<BPUProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await bpuProvider.getproductFormAndPackageList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<BPUProvider>(builder: (context, bpuProvider, _) {
        return PopScope(
          onPopInvoked: (didPop) {
            bpuProvider.errorMessages.clear();
            bpuProvider.validProducts.clear();
            bpuProvider.isReadyToUpload = false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverCustomAppbar(
                title: 'Bulk Product Upload',
                onBackTap: () {
                  bpuProvider.errorMessages.clear();
                  bpuProvider.validProducts.clear();
                  bpuProvider.isReadyToUpload = false;
                  Navigator.pop(context);
                },
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        child: Text(
                            'Available values to set in product sheet :',
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontSize: 15,
                                    )),
                      ),
                      Wrap(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 4,
                            ),
                            child: DropDownProductButton(
                                value: '',
                                hintText: 'Ideal for',
                                onChanged: (value) {},
                                optionList: bpuProvider.idealForOptionList),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 4,
                            ),
                            child: DropDownProductButton(
                                value: '',
                                hintText: 'Units',
                                onChanged: (value) {},
                                optionList: bpuProvider.measurmentOptionList),
                          ),
                        ],
                      ),
                      Wrap(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 4,
                            ),
                            child: DropDownProductButton(
                                value: '',
                                hintText: 'Medicine Form',
                                onChanged: (value) {},
                                optionList: bpuProvider.medicineFormList),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 4,
                            ),
                            child: DropDownProductButton(
                                value: '',
                                hintText: 'Others Form',
                                onChanged: (value) {},
                                optionList: bpuProvider.othersFormList),
                          ),
                        ],
                      ),
                      Wrap(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 4,
                            ),
                            child: DropDownProductButton(
                                value: '',
                                hintText: 'Medicine Package',
                                onChanged: (value) {},
                                optionList: bpuProvider.medicinePackageList),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 4,
                            ),
                            child: DropDownProductButton(
                                value: '',
                                hintText: 'Others Package',
                                onChanged: (value) {},
                                optionList: bpuProvider.othersPackageList),
                          ),
                        ],
                      ),
                      Wrap(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 4,
                            ),
                            child: DropDownProductButton(
                                value: '',
                                hintText: 'Equipment Types',
                                onChanged: (value) {},
                                optionList: bpuProvider.equipmentTypeList),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 4,
                            ),
                            child: DropDownProductButton(
                                value: '',
                                hintText: 'Others Types',
                                onChanged: (value) {},
                                optionList: bpuProvider.othersCategoryTypeList),
                          ),
                        ],
                      ),
                      DropDownProductButton(
                          value: '',
                          hintText: 'Time Period',
                          onChanged: (value) {},
                          optionList: bpuProvider.warantyOptionList),
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 24),
                        child: Text(
                            'Choose product type and upload product sheet accordingly :',
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontSize: 15,
                                    )),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Gap(4),
                          Expanded(
                            child: PharmacyProductChooseButton(
                              buttonTap: () {
                                bpuProvider.errorMessages.clear();
                                bpuProvider.validProducts.clear();
                                bpuProvider.getCSV(context: context).then(
                                  (file) {
                                    if (file != null) {
                                      bpuProvider.typeOfProduct = 'Medicine';
                                      LoadingLottie.showLoading(
                                          context: context,
                                          text: 'Please wait..');
                                      bpuProvider.importCSV(file).whenComplete(
                                        () {
                                          Navigator.pop(context);
                                        },
                                      );
                                    }
                                  },
                                );
                              },
                              text: 'Medicine',
                              icon: Icons.medication,
                              iconColor: BColors.mainlightColor,
                            ),
                          ),
                          const Gap(4),
                          Expanded(
                            child: PharmacyProductChooseButton(
                              buttonTap: () {
                                bpuProvider.errorMessages.clear();
                                bpuProvider.validProducts.clear();
                                bpuProvider.getCSV(context: context).then(
                                  (file) async {
                                    if (file != null) {
                                      bpuProvider.typeOfProduct = 'Equipment';
                                      LoadingLottie.showLoading(
                                          context: context,
                                          text: 'Please wait..');
                                      await bpuProvider
                                          .importCSV(file)
                                          .whenComplete(
                                        () {
                                          Navigator.pop(context);
                                        },
                                      );
                                    }
                                  },
                                );
                              },
                              text: 'Equipment',
                              icon: Icons.devices_other_rounded,
                              iconColor: BColors.mainlightColor,
                            ),
                          ),
                          const Gap(4),
                          Expanded(
                            child: PharmacyProductChooseButton(
                              buttonTap: () {
                                bpuProvider.errorMessages.clear();
                                bpuProvider.validProducts.clear();
                                bpuProvider.getCSV(context: context).then(
                                  (file) {
                                    if (file != null) {
                                      bpuProvider.typeOfProduct = 'Others';
                                      LoadingLottie.showLoading(
                                          context: context,
                                          text: 'Please wait..');
                                      bpuProvider.importCSV(file).whenComplete(
                                        () {
                                          Navigator.pop(context);
                                        },
                                      );
                                    }
                                  },
                                );
                              },
                              text: "Others",
                              icon: Icons.shopping_bag_rounded,
                              iconColor: BColors.mainlightColor,
                            ),
                          ),
                          const Gap(4),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              (bpuProvider.errorMessages.isNotEmpty)
                  ? SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      sliver: SliverList.builder(
                        itemCount: bpuProvider.errorMessages.length,
                        itemBuilder: (context, index) {
                          return Text(bpuProvider.errorMessages[index],
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(
                                      fontSize: 15, color: BColors.offRed));
                        },
                      ),
                    )
                  : (bpuProvider.isReadyToUpload &&
                          bpuProvider.validProducts.isNotEmpty)
                      ? SliverPadding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Products are ready to upload!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                            fontSize: 16,
                                            color: BColors.green)),
                                const Gap(2),
                                Text('Tap below to upload.',
                                    style:
                                        Theme.of(context).textTheme.labelSmall),
                                const Gap(8),
                                CustomButton(
                                    width: double.infinity,
                                    height: 48,
                                    onTap: () {
                                      LoadingLottie.showLoading(
                                          context: context,
                                          text: 'Please wait...');
                                      bpuProvider.addPharmacyProductDetails(
                                          context: context);
                                    },
                                    icon: Icons.check_circle_outline_outlined,
                                    iconColor: Colors.white,
                                    text:
                                        'Upload ${bpuProvider.typeOfProduct} Sheet',
                                    buttonColor: BColors.buttonLightBlue,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .copyWith(
                                          fontSize: 16,
                                          color: Colors.white,
                                        )),
                              ],
                            ),
                          ),
                        )
                      : const SliverToBoxAdapter()
            ],
          ),
        );
      }),
    );
  }
}
