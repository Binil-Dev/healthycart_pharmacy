// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:healthycart_pharmacy/core/custom/app_bar/sliver_appbar.dart';
import 'package:healthycart_pharmacy/core/custom/custom_buttons_and_search/common_button.dart';
import 'package:healthycart_pharmacy/core/custom/divider/divider.dart';
import 'package:healthycart_pharmacy/core/custom/lottie/loading_lottie.dart';
import 'package:healthycart_pharmacy/core/custom/text_formfield/textformfield.dart';
import 'package:healthycart_pharmacy/core/custom/toast/toast.dart';
import 'package:healthycart_pharmacy/core/general/validator.dart';
import 'package:healthycart_pharmacy/core/services/easy_navigation.dart';
import 'package:healthycart_pharmacy/features/add_pharmacy_form_page/application/pharmacy_form_provider.dart';
import 'package:healthycart_pharmacy/features/add_pharmacy_form_page/domain/model/pharmacy_model.dart';
import 'package:healthycart_pharmacy/features/add_pharmacy_form_page/presentation/widgets/container_image_widget.dart';
import 'package:healthycart_pharmacy/features/add_pharmacy_form_page/presentation/widgets/pdf_shower_widget.dart';
import 'package:healthycart_pharmacy/features/add_pharmacy_form_page/presentation/widgets/text_above_form_widdget.dart';
import 'package:healthycart_pharmacy/features/authenthication/application/authenication_provider.dart';
import 'package:healthycart_pharmacy/features/location_picker/application/location_provider.dart';
import 'package:healthycart_pharmacy/features/location_picker/domain/model/location_model.dart';
import 'package:healthycart_pharmacy/features/location_picker/presentation/location_search.dart';
import 'package:healthycart_pharmacy/utils/constants/colors/colors.dart';
import 'package:provider/provider.dart';

class PharmacyFormScreen extends StatelessWidget {
  const PharmacyFormScreen(
      {super.key, this.pharmacyModel, this.placeMark, this.isEditing});
  final PharmacyModel? pharmacyModel;
  final PlaceMark? placeMark;
  final bool? isEditing;
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (pharmacyModel != null) {
        context
            .read<PharmacyFormProvider>()
            .setEditData(pharmacyModel ?? PharmacyModel());
      }
    });
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    // authenication provider is getting here to show the location details
    return Consumer2<PharmacyFormProvider, AuthenticationProvider>(
        builder: (context, pharmacyProvider, authProvider, _) {
      return Scaffold(
          backgroundColor: const Color(0xFFF5F3F3),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: PopScope(
              canPop: (pharmacyProvider.pdfUrl != null),
              onPopInvoked: (didPop) {
                if (pharmacyProvider.pdfUrl == null) {
                  CustomToast.sucessToast(text: 'Please add PDF');
                  return;
                }
              },
              child: CustomScrollView(
                slivers: [
                  (isEditing == true)
                      ? SliverCustomAppbar(
                          title: 'Edit Profile',
                          onBackTap: () {
                            if (pharmacyProvider.pdfUrl == null) {
                              CustomToast.sucessToast(text: 'Please add PDF');
                              return;
                            }
                            Navigator.pop(context);
                          },
                        )
                      : const SliverToBoxAdapter(),
                  SliverFillRemaining(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              (isEditing == true)
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            color: BColors.mainlightColor,
                                          ),
                                          SizedBox(
                                            width: 176,
                                            child: GestureDetector(
                                              onTap: () {
                                                LoadingLottie.showLoading(
                                                    context: context,
                                                    text:
                                                        'Getting Location...');
                                                context
                                                    .read<LocationProvider>()
                                                    .getLocationPermisson()
                                                    .then(
                                                  (value) {
                                                    if (value == false) {
                                                      CustomToast.errorToast(
                                                          text:
                                                              'Please enable location.');
                                                      return;
                                                    }
                                                    EasyNavigation.pop(
                                                        context: context);
                                                    EasyNavigation.push(
                                                      context: context,
                                                      page: const UserLocationSearchWidget(
                                                          isPharmacyEditProfile: true),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Text(
                                                "${authProvider.pharmacyDataFetched?.placemark?.localArea},${authProvider.pharmacyDataFetched?.placemark?.district},${authProvider.pharmacyDataFetched?.placemark?.state}",
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: BColors.darkblue,
                                                    decoration: TextDecoration
                                                        .underline),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(),
                              const Gap(24),
                              const ImageFormContainerWidget(),
                              const Gap(16),
                              const DividerWidget(
                                  text: 'Tap above to add image'),
                              const Gap(24),
                              const TextAboveFormFieldWidget(
                                  starText: true, text: "Phone Number"),
                              TextfieldWidget(
                                readOnly: true,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.phone,
                                validator: BValidator.validate,
                                controller: pharmacyProvider
                                    .pharmacyPhoneNumberController,
                              ),
                              const Gap(8),
                              //hospital Name
                              const TextAboveFormFieldWidget(
                                starText: true,
                                text: "Pharmacy Name",
                              ),

                              TextfieldWidget(
                                hintText: 'Enter Pharmacy name',
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.multiline,
                                minlines: 1,
                                maxlines: 2,
                                validator: BValidator.validate,
                                controller:
                                    pharmacyProvider.pharmacyNameController,
                              ),
                              const Gap(8),

                              const TextAboveFormFieldWidget(
                                  starText: true, text: "Proprietor Name"),
                              TextfieldWidget(
                                hintText: 'Enter Proprietor name',
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.name,
                                validator: BValidator.validate,
                                controller: pharmacyProvider
                                    .pharmacyOwnerNameController,
                              ),
                              const Gap(8),

                              const TextAboveFormFieldWidget(
                                  starText: true, text: "Pharmacy email"),
                              TextfieldWidget(
                                hintText: 'Enter email id',
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.emailAddress,
                                validator: BValidator.validateEmail,
                                controller:
                                    pharmacyProvider.pharmacyEmailController,
                              ),
                              const Gap(8),

                              const TextAboveFormFieldWidget(
                                  starText: true, text: "Pharmacy Address"),
                              TextfieldWidget(
                                hintText: 'Enter pharmacy address',
                                textInputAction: TextInputAction.done,
                                validator: BValidator.validate,
                                controller:
                                    pharmacyProvider.pharmacyAddressController,
                                maxlines: 3,
                              ),
                              const Gap(16),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await pharmacyProvider.getPDF(
                                        context: context); /////////pdf Section
                                  },
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      backgroundColor:
                                          BColors.buttonLightColor),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Upload License',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge!
                                              .copyWith(
                                                  fontSize: 16,
                                                  color: BColors.white)),
                                      const Icon(
                                        Icons.upload_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Gap(16),

                              (pharmacyProvider.pdfUrl != null)
                                  ? Center(
                                      child: PDFShowerWidget(
                                        pharmacyProvider: pharmacyProvider,
                                      ),
                                    )
                                  : const DividerWidget(
                                      text: 'Upload document as PDF'),
                              const Gap(24),
                              CustomButton(
                                  width: double.infinity,
                                  height: 48,
                                  onTap: () async {
                                    if (pharmacyProvider.imageFile == null &&
                                        pharmacyProvider.imageUrl == null) {
                                      CustomToast.errorToast(
                                          text: 'Pick pharmacy image');
                                      return;
                                    }
                                    if (!formKey.currentState!.validate()) {
                                      formKey.currentState!.validate();
                                      return;
                                    }
                                    if (pharmacyProvider.pdfFile == null &&
                                        pharmacyProvider.pdfUrl == null) {
                                      CustomToast.errorToast(
                                          text:
                                              'Pick a pharmacy liscense document.');
                                      return;
                                    }
                                    LoadingLottie.showLoading(
                                        context: context,
                                        text: 'Please wait...');
                                    if (pharmacyModel?.pharmacyRequested != 2) {
                                      // here we are checking if the hospital was not in review
                                      await pharmacyProvider
                                          .saveImage()
                                          .then((value) async {
                                        await pharmacyProvider
                                            .addPharmacyDetails(
                                                context: context);
                                      });
                                    } else {
                                      if (pharmacyProvider.imageUrl == null) {
                                        await pharmacyProvider.saveImage();
                                      }

                                      await pharmacyProvider.updatePharmacyForm(
                                        context: context,
                                      );
                                    }
                                  },
                                  text: (pharmacyModel?.pharmacyRequested != 2)
                                      ? 'Send for review'
                                      : 'Update details',
                                  buttonColor: BColors.buttonDarkColor,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(
                                          fontSize: 18, color: BColors.white))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ));
    });
  }
}
