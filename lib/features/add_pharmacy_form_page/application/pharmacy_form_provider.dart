import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:healthycart_pharmacy/core/custom/keyword_builder/keyword_builder.dart';
import 'package:healthycart_pharmacy/core/custom/lottie/loading_lottie.dart';
import 'package:healthycart_pharmacy/core/custom/toast/toast.dart';
import 'package:healthycart_pharmacy/core/failures/main_failure.dart';
import 'package:healthycart_pharmacy/core/general/typdef.dart';
import 'package:healthycart_pharmacy/core/services/easy_navigation.dart';
import 'package:healthycart_pharmacy/features/add_pharmacy_form_page/domain/i_form_facade.dart';
import 'package:healthycart_pharmacy/features/add_pharmacy_form_page/domain/model/pharmacy_model.dart';
import 'package:healthycart_pharmacy/features/home/presentation/home.dart';
import 'package:healthycart_pharmacy/features/location_picker/presentation/location.dart';
import 'package:injectable/injectable.dart';
import 'package:page_transition/page_transition.dart';

@injectable
class PharmacyFormProvider extends ChangeNotifier {
  PharmacyFormProvider(this._iFormFeildFacade);
  final IFormFeildFacade _iFormFeildFacade;
//Image section
  String? imageUrl;
  File? imageFile;
  bool fetchLoading = false;

  Future<void> getImage() async {
      String? pharmacyId = FirebaseAuth.instance.currentUser?.uid;
    final result = await _iFormFeildFacade.getImage();
    result.fold((failure) {
      CustomToast.errorToast(text: failure.errMsg);
      notifyListeners();
    }, (imageFilesucess) async {
      if (imageUrl != null) {
        await _iFormFeildFacade.deleteImage(
            imageUrl: imageUrl!, pharmacyId: pharmacyId ?? '');
        imageUrl = null;
      } // when editing  this will make the url null when we pick a new file
      imageFile = imageFilesucess;
      notifyListeners();
    });
  }

  Future<void> saveImage() async {
    if (imageFile == null && imageUrl == null) {
      CustomToast.errorToast(text: 'Please check the image selected.');
      return;
    }
    final result = await _iFormFeildFacade.saveImage(imageFile: imageFile!);
    result.fold((failure) {
      CustomToast.errorToast(text: failure.errMsg);
    }, (imageurlGet) {
      imageUrl = imageurlGet;
      notifyListeners();
    });
  }

  final TextEditingController pharmacyNameController = TextEditingController();
  final TextEditingController pharmacyAddressController =
      TextEditingController();
  final TextEditingController pharmacyPhoneNumberController =
      TextEditingController();
  final TextEditingController pharmacyOwnerNameController =
      TextEditingController();
  final TextEditingController pharmacyEmailController = TextEditingController();
  List<String> keywordHospitalBuider() {
    return keywordsBuilder(pharmacyNameController.text);
  }

  PharmacyModel? pharmacyData;

  Placemark? placemark;
  Future<void> addPharmacyDetails({
    required BuildContext context,
  }) async {
      String? pharmacyId = FirebaseAuth.instance.currentUser?.uid;
    keywordHospitalBuider();
    pharmacyData = PharmacyModel(
      id: pharmacyId,
      createdAt: Timestamp.now(),
      pharmacyKeywords: keywordHospitalBuider(),
      phoneNo: pharmacyPhoneNumberController.text,
      pharmacyName: pharmacyNameController.text,
      pharmacyAddress: pharmacyAddressController.text,
      pharmacyownerName: pharmacyOwnerNameController.text,
      email: pharmacyEmailController.text,
      pharmacyDocumentLicense: pdfUrl,
      pharmacyImage: imageUrl,
      isActive: true,
      isHomeDelivery: false,
      isPharmacyON: false,
      pharmacyRequested: 1,
    );

    final result = await _iFormFeildFacade.addPharmacyDetails(
      pharmacyDetails: pharmacyData ?? PharmacyModel(),
      pharmacyId: pharmacyId!,
    );
    result.fold((failure) {
      CustomToast.errorToast(text: failure.errMsg);
      Navigator.pop(context);
    }, (sucess) {
      clearAllData();
      CustomToast.sucessToast(text: sucess);
      Navigator.pop(context);
      EasyNavigation.pushReplacement(
        type: PageTransitionType.bottomToTop,
        context: context,
        page: const LocationPage(),
      );
      notifyListeners();
    });
  }

  void clearAllData() {
    pharmacyNameController.clear();
    pharmacyAddressController.clear();
    pdfFile = null;
    pdfUrl = null;
    imageFile = null;
    imageUrl = null;
    pharmacyPhoneNumberController.clear();
    pharmacyOwnerNameController.clear();
    pharmacyEmailController.clear();
    notifyListeners();
  }

/////////////////////////// pdf-----------
  ///

  File? pdfFile;
  String? pdfUrl;

  Future<void> getPDF({required BuildContext context}) async {
      String? pharmacyId = FirebaseAuth.instance.currentUser?.uid;
    final result = await _iFormFeildFacade.getPDF();
    result.fold((failure) {
      CustomToast.errorToast(text: failure.errMsg);
      notifyListeners();
    }, (pdfFileSucess) async {
      LoadingLottie.showLoading(
          context: context, text: 'Uploading document...');
      if (pdfUrl != null) {
        await _iFormFeildFacade.deletePDF(
            pdfUrl: pdfUrl ?? '', pharmacyId: pharmacyId ?? '');
        pdfUrl = null;
      }
      pdfFile = pdfFileSucess;
      await savePDF().then((value) {
        // save PDF function is called here......
        value.fold((failure) {
          EasyNavigation.pop(context: context);
          notifyListeners();
          return CustomToast.errorToast(text: failure.errMsg);
        }, (pdfUrlSucess) {
          pdfUrl = pdfUrlSucess;
          EasyNavigation.pop(context: context);
          notifyListeners();
          return CustomToast.sucessToast(text: 'PDF Added Sucessfully');
        });
      });
    });
  }

  FutureResult<String?> savePDF() async {
    if (pdfFile == null) {
      return left(const MainFailure.generalException(
          errMsg: 'Please check the PDF selected.'));
    }
    final result = await _iFormFeildFacade.savePDF(pdfFile: pdfFile!);
    return result;
  }

  Future<void> deletePDF() async {
      String? pharmacyId = FirebaseAuth.instance.currentUser?.uid;
    if ((pdfUrl ?? '').isEmpty) {
      pdfFile = null;
      CustomToast.errorToast(text: 'PDF removed.');
      notifyListeners();
      return;
    }
    final result = await _iFormFeildFacade.deletePDF(
        pdfUrl: pdfUrl ?? '', pharmacyId: pharmacyId ?? '');
    result.fold((failure) {
      CustomToast.errorToast(text: failure.errMsg);
      notifyListeners();
    }, (sucess) {
      pdfFile = null;
      pdfUrl = null;
      CustomToast.sucessToast(text: sucess!);
      notifyListeners();
    });
  }

  ///edit data from the profile section
  void setEditData(PharmacyModel pharmacyDataEdit) {
    pharmacyNameController.text = pharmacyDataEdit.pharmacyName ?? '';
    pharmacyAddressController.text = pharmacyDataEdit.pharmacyAddress ?? '';
    pharmacyPhoneNumberController.text = pharmacyDataEdit.phoneNo ?? '';
    pharmacyOwnerNameController.text = pharmacyDataEdit.pharmacyownerName ?? '';
    pharmacyEmailController.text = pharmacyDataEdit.email ?? '';
    pdfUrl = pharmacyDataEdit.pharmacyDocumentLicense;
    imageUrl = pharmacyDataEdit.pharmacyImage;
    notifyListeners();
  }

  Future<void> updatePharmacyForm({
    required BuildContext context,
  }) async {
      String? pharmacyId = FirebaseAuth.instance.currentUser?.uid;
    keywordHospitalBuider();
    pharmacyData = PharmacyModel(
      pharmacyKeywords: keywordHospitalBuider(),
      phoneNo: pharmacyPhoneNumberController.text,
      pharmacyName: pharmacyNameController.text,
      pharmacyAddress: pharmacyAddressController.text,
      pharmacyownerName: pharmacyOwnerNameController.text,
      email: pharmacyEmailController.text,
      pharmacyDocumentLicense: pdfUrl,
      pharmacyImage: imageUrl,
    );

    final result = await _iFormFeildFacade.updatePharmacyForm(
        pharmacyDetails: pharmacyData!, pharmacyId: pharmacyId!);

    result.fold((failure) {
      CustomToast.errorToast(text: failure.errMsg);
      Navigator.pop(context);
    }, (sucess) {
      clearAllData();
      CustomToast.sucessToast(text: 'Sucessfully updated details.');
      Navigator.pop(context);
      EasyNavigation.pushReplacement(
        type: PageTransitionType.bottomToTop,
        context: context,
        page: const HomeScreen(),
      );
      // when edited moving back to the profile screen
      notifyListeners();
    });
  }
}
