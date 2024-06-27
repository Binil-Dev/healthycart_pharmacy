import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart_pharmacy/utils/constants/colors/colors.dart';
import 'package:healthycart_pharmacy/utils/constants/image/image.dart';


class NoDataImageWidget extends StatelessWidget {
  const NoDataImageWidget({
    super.key,
    required this.text,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
       mainAxisSize: MainAxisSize.min,   
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          BImage.noDataPng,
          scale: 2.5,
        ),
        const Gap(16),
        Text(
          text,
          style: const TextStyle(
              fontSize: 14, color: BColors.textLightBlack, fontWeight: FontWeight.w500),
        ),
      ],
    ));
  }
}


class ErrorOrNoDataPage extends StatelessWidget {
  const ErrorOrNoDataPage({
    super.key,required this.text,
  });
final String text;
  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Column(
         mainAxisSize: MainAxisSize.min,  
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            BImage.noDataPng,
             scale: 2.5,
          ),
          const Gap(16),
           Text(
             text,
             textAlign: TextAlign.center,
             style: const TextStyle(
                 fontFamily: 'Montserrat',
                 fontSize: 14,
                 fontWeight: FontWeight.w500,
                 color: BColors.textLightBlack),
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
           ),
        ],
      ),
    );
  }
}
