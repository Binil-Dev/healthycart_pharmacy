import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart_pharmacy/utils/constants/colors/colors.dart';

class QuantityCountWidget extends StatelessWidget {
  const QuantityCountWidget({
    super.key,
    required this.incrementTap,
    required this.decrementTap,
    required this.quantityValue,
    required this.removeTap,
  });
  final VoidCallback incrementTap;
  final VoidCallback decrementTap;
  final VoidCallback removeTap;
  final int quantityValue;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        (quantityValue <= 1)
            ? Material(
                color: BColors.white,
                surfaceTintColor: BColors.white,
                borderRadius: BorderRadius.circular(8),
                elevation: 3,
                child: GestureDetector(
                  onTap: removeTap,
                  child: SizedBox(
                      height: 32,
                      width: 32,
                      child: Icon(
                        Icons.delete_forever_outlined,
                        size: 24,
                        color: BColors.offRed,
                      )),
                ),
              )
            : Material(
                color: BColors.white,
                surfaceTintColor: BColors.white,
                borderRadius: BorderRadius.circular(8),
                elevation: 3,
                child: GestureDetector(
                  onTap: decrementTap,
                  child: SizedBox(
                      height: 32,
                      width: 32,
                      child: Icon(
                        Icons.remove,
                        size: 24,
                        color: BColors.mainlightColor,
                      )),
                ),
              ),
        const Gap(8),
        Material(
          color: BColors.white,
          surfaceTintColor: BColors.white,
          borderRadius: BorderRadius.circular(8),
          elevation: 3,
          child: SizedBox(
              height: 32,
              width: 40,
              child: Center(
                  child: Text(
                quantityValue.toString(),
                style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: BColors.darkblue),
              ))),
        ),
        const Gap(8),
        Material(
          color: BColors.white,
          surfaceTintColor: BColors.white,
          borderRadius: BorderRadius.circular(8),
          elevation: 3,
          child: GestureDetector(
            onTap: incrementTap,
            child: SizedBox(
                height: 32,
                width: 32,
                child: Icon(
                  Icons.add,
                  size: 24,
                  color: BColors.mainlightColor,
                )),
          ),
        )
      ],
    );
  }
}
