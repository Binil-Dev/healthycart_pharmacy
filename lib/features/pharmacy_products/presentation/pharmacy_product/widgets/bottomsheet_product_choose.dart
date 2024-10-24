import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart_pharmacy/core/services/easy_navigation.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/application/pharmacy_provider.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/presentation/pharmacy_product/widgets/forms_widget/equipment_add_form.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/presentation/pharmacy_product/widgets/forms_widget/medicine_add_form.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/presentation/pharmacy_product/widgets/forms_widget/other_add_form.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/presentation/pharmacy_product/widgets/product_choose_button_widget.dart';
import 'package:healthycart_pharmacy/utils/constants/colors/colors.dart';
import 'package:provider/provider.dart';

class ChooseProductBottomSheet extends StatelessWidget {
  const ChooseProductBottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final pharmacyProvider = Provider.of<PharmacyProvider>(context);
    return SizedBox(
      height: 200,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            child: Text('Choose product type :',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
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
                    pharmacyProvider.clearProductDetails();
                    EasyNavigation.push(
                        context: context,
                        page: const MedicineAddFormWidget(
                          typeOfProduct: 'Medicine',
                          isEditing: false,
                        ));
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
                    pharmacyProvider.clearProductDetails();
                    EasyNavigation.push(
                        context: context,
                        page: const EquipmentAddFormWidget(
                          typeOfProduct: 'Equipment',
                          isEditing: false,
                        ));
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
                    pharmacyProvider.clearProductDetails();
                    EasyNavigation.push(
                        context: context,
                        page: const OtherAddFormWidget(
                          typeOfProduct: "Others",
                          isEditing: false,
                        ));
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
    );
  }
}
