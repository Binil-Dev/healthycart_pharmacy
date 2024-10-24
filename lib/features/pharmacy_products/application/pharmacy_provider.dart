// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:healthycart_pharmacy/core/custom/keyword_builder/keyword_builder.dart';
import 'package:healthycart_pharmacy/core/custom/lottie/loading_lottie.dart';
import 'package:healthycart_pharmacy/core/custom/toast/toast.dart';
import 'package:healthycart_pharmacy/core/services/easy_navigation.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/domain/i_pharmacy_facade.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/domain/model/pharmacy_category_model.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/domain/model/pharmacy_product_model.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/domain/model/product_type_model.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

@injectable
class PharmacyProvider extends ChangeNotifier {
  PharmacyProvider(this._iPharmacyFacade);
  final IPharmacyFacade _iPharmacyFacade;
/////////////////////////////////////

  ///////////////////////
  ///Image section ---------------------------
  bool fetchLoading = false;
  bool fetchAlertLoading = false;
  bool onTapBool = false;

  void onTapEditButton() {
    // to change to long press and ontap
    onTapBool = !onTapBool;
    notifyListeners();
  }

//////////////////////////
  /// adding pharmacy category -----------------------------------------
  ///
  /// radio button

  PharmacyCategoryModel? selectedRadioButtonCategoryValue;
  void selectedRadioButton({
    required PharmacyCategoryModel result,
  }) {
    selectedRadioButtonCategoryValue = result;

    notifyListeners();
  }

  List<PharmacyCategoryModel> pharmacyCategoryAllList = [];
  List<String> pharmacyCategoryIdList =
      []; // to get id of category from the product list
  List<PharmacyCategoryModel> pharmacyCategoryList = [];
  PharmacyCategoryModel? pharmacyCategory;
  List<PharmacyCategoryModel> pharmacyCategoryUniqueList = [];
////getting category of pharmacy from admin side
  Future<void> getPharmacyCategoryAll() async {
    if (pharmacyCategoryAllList.isNotEmpty) return;
    fetchAlertLoading = true;
    notifyListeners();
    final result = await _iPharmacyFacade.getPharmacyCategoryAll();
    result.fold((failure) {
      CustomToast.errorToast(text: "Couldn't able to fetch category");
      fetchLoading = false;
      notifyListeners();
    }, (categoryAllList) {
      pharmacyCategoryAllList.addAll(categoryAllList);
      pharmacyCategoryUniqueList.addAll(pharmacyCategoryAllList);
    });
    fetchAlertLoading = false;
    notifyListeners();
  }

  Future<void> getpharmacyCategory() async {
    if (pharmacyCategoryList.isNotEmpty) return;
    fetchLoading = true;
    notifyListeners();
    final result = await _iPharmacyFacade.getpharmacyCategory(
        categoryIdList: pharmacyCategoryIdList);
    result.fold((failure) {
      CustomToast.errorToast(text: "Couldn't able to fetch category");
      fetchLoading = false;
      notifyListeners();
    }, (categoryList) {
      pharmacyCategoryList.addAll(categoryList);
    });
    fetchLoading = false;
    notifyListeners();
  }

  void removingFromUniqueCategoryList() {
    for (var element in pharmacyCategoryList) {
      pharmacyCategoryUniqueList.removeWhere((cat) {
        return cat.id == element.id;
      });
      notifyListeners();
    }
  }

  /// update the category in pharmacy
  Future<void> updatePharmacyCategoryDetails(
      {required PharmacyCategoryModel categorySelected,}) async {
        
  String? pharmacyId =
      FirebaseAuth.instance.currentUser?.uid;
    final result = await _iPharmacyFacade.updatePharmacyCategoryDetails(
        pharmacyId: pharmacyId ?? '', category: categorySelected);
    result.fold((failure) {
      CustomToast.errorToast(text: "Couldn't able to update category");
    }, (categorymodel) {
      pharmacyCategoryList.insert(pharmacyCategoryList.length, categorymodel);
      removingFromUniqueCategoryList();
      notifyListeners();
    });
    return;
  }

///////////////////////
//////// Deleting pharmacy category-----------------------
  Future<void> deletePharmacyCategory(
      {required int index, required PharmacyCategoryModel category}) async {
        
  String? pharmacyId =
      FirebaseAuth.instance.currentUser?.uid;
    // check if there is any pharmacy inside category that is going to be deleted
    final boolResult =
        await _iPharmacyFacade.checkProductInsidePharmacyCategory(
            categoryId: category.id ?? 'No categoryId',
            pharmacyId: pharmacyId ?? ' No pharmacy Id is here..');
    boolResult.fold((failure) {
      CustomToast.errorToast(text: "Something went wrong,please try again");
    }, (sucess) async {
      if (sucess) {
        CustomToast.errorToast(text: "Can't remove, there is product's inside");
      } else {
        final result = await _iPharmacyFacade.deletePharmacyCategory(
            pharmacyId: pharmacyId!, category: category);
        result.fold((failure) {
          CustomToast.errorToast(
              text: "Can't able to remove the category,please try again.");
        }, (category) {
          pharmacyCategoryList.removeAt(index);
          pharmacyCategoryUniqueList.add(category);
          CustomToast.sucessToast(text: 'Sucessfully removed.');
          notifyListeners();
        });
      }
    });
  }

/////////////////////////////////////////////
//---------------------------Product  Section---------------------------------
 // user id and pharmacy id is same
  String? categoryId;

  /// these both are used in the category also to check wheather the user

  ///////////////////////////////////// 1.)  Adding ImageList----------

// image section of adding product
  List<String> imageProductUrlList = [];

  Future<void> getProductImageList({
    required BuildContext context,
  }) async {
    final maxImages = 3 - imageProductUrlList.length;
    await _iPharmacyFacade
        .getProductImageList(maxImages: maxImages)
        .then((result) {
      result.fold((failure) {
        CustomToast.errorToast(text: failure.errMsg);
      }, (imageFileList) async {
        LoadingLottie.showLoading(context: context, text: 'Please wait...');
        notifyListeners();
        await _iPharmacyFacade
            .saveProductImageList(imageFileList: imageFileList)
            .then((value) {
          value.fold((failure) {
            CustomToast.errorToast(text: failure.errMsg);
            EasyNavigation.pop(context: context);
          }, (imageUrlList) {
            imageProductUrlList.addAll(imageUrlList);
            notifyListeners();
            EasyNavigation.pop(context: context);
            CustomToast.sucessToast(text: 'Sucessfully picked an image');
          });
        });
      });
    });
  }

  int selectedImageIndex = 0;
  void setselectedImageIndex(int index) {
    selectedImageIndex = index;
    notifyListeners();
  }

  List<String> deleteUrlList = [];
  void deletedUrl({required String selectedImageUrl}) {
    selectedImageIndex = 0;
    imageProductUrlList.remove(selectedImageUrl);
    deleteUrlList.add(selectedImageUrl);
    notifyListeners();
  }

  Future<void> deleteProductImage({
    required BuildContext context,
    required int index,
    required String selectedImageUrl,

    /// check this when editing......
  }) async {
    await _iPharmacyFacade
        .deleteImage(imageUrl: selectedImageUrl)
        .then((value) {
      value.fold((failure) {
        CustomToast.errorToast(text: failure.errMsg);
      }, (sucess) {
        selectedImageIndex = 0;
        imageProductUrlList.removeAt(index);
        notifyListeners();
        CustomToast.sucessToast(text: 'Sucessfully removed');
      });
    });
  }

  Future<void> deleteProductImageList({required List<String> imageUrls}) async {
    await _iPharmacyFacade.deleteProductImageList(imageUrlList: imageUrls);
  }

  ///Medicine form section
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productBrandNameController =
      TextEditingController();
  final TextEditingController productMRPController = TextEditingController();
  final TextEditingController productDiscountRateController =
      TextEditingController();
 // final TextEditingController totalQuantityController = TextEditingController();
  final TextEditingController storeBelowController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController productFormNumberController =
      TextEditingController();
  final TextEditingController productPackageNumberController =
      TextEditingController();
  final TextEditingController measurementUnitNumberController =
      TextEditingController();
  final TextEditingController keyIngredientController = TextEditingController();
  final TextEditingController productInformationController =
      TextEditingController();
  final TextEditingController directionToUseController =
      TextEditingController();
  final TextEditingController safetyInformationController =
      TextEditingController();
  final TextEditingController keyBenefitController = TextEditingController();
  final TextEditingController productBoxContainsController =
      TextEditingController();
  final TextEditingController productWarrantyController =
      TextEditingController();

  bool? discountAvailable;
  bool? prescriptionNeeded;
  int? discountPercentage;
  DateTime? expiryDate;
  String? selectedCategoryText;

//bool for setting instock or out of stock;
  Future<void> setSelectedProductStock({required String id}) async {
    PharmacyProductAddModel getProd =
        productList.firstWhere((element) => element.id == id);
    getProd = getProd.copyWith(inStock: !(getProd.inStock ?? true));
    final index = productList.indexWhere((element) => element.id == id);

    final result = await _iPharmacyFacade.setStatusOfProductStock(isProductInStock: getProd.inStock ?? true, productId: id);

    result.fold(
      (failure) {
        CustomToast.errorToast(text: failure.errMsg);
      },
      (sucesss) {
        CustomToast.sucessToast(
            text: sucesss
                ? 'Updated item as in stock'
                : 'Updated item as out of stock');
        productList[index] = getProd;
        notifyListeners();
      },
    );
  }

//bool setter for discout
  void discountAvailableboolSetter(bool? value) {
    discountAvailable = value ?? false;
    notifyListeners();
  }

  void prescriptionNeededboolSetter(bool? value) {
    prescriptionNeeded = value ?? false;
    notifyListeners();
  }

//calculating the discount
  void discountPercentageCalculator() {
    double discountRate = double.tryParse(productDiscountRateController.text)!;
    double mrp = double.tryParse(productMRPController.text)!;
    double discountAmount = mrp - discountRate;
    double decimal = discountAmount / mrp;
    discountPercentage = (decimal * 100).toInt();
    notifyListeners();
  }

// adding the categoryId and type
  String? typeOfProduct;
  void selectedProductType({String? catId, String? selectedCategory}) {
    selectedCategoryText = selectedCategory;
    categoryId = catId ?? '';
    notifyListeners();
  }

  ///setting  expiryDate
  void expiryDateSetter(DateTime? date) {
    expiryDate = date;
    expiryDateController.text = DateFormat('yyyy-MM').format(date!);
    notifyListeners();
  }

  String expiryDateSetterFetched(Timestamp expiryDate) {
    final DateTime date =
        DateTime.fromMillisecondsSinceEpoch(expiryDate.millisecondsSinceEpoch);
    final String result = DateFormat('yyyy-MM').format(date);
    return result;
  }

  List<String> measurmentOptionList = [
    'L (Litre)',
    'mL (Millilitre)',
    'cc (Cubic cm)',
    'Kg (Kilogram)',
    'g (Gram)',
    'mg (Milligram)',
    'µg (Microgram)'
  ];
  List<String> warantyOptionList = ['Months', 'Years'];
  List<String> idealForOptionList = [
    'Infants',
    'Toddlers',
    'Children',
    'Teenagers',
    'Adults',
    'Elderly',
    'Men',
    'Women',
    'Everyone',
    'Both men & women',
  ];
  /* -------------------------------------------------------------------------- */
  // getting from the admin side

  /* -------------------------------------------------------------------------- */

  String? productForm;
  String? productPackage;
  String? productType;

  String? productMeasurementUnit;
  String? selectedWarantyOption;
  String? idealFor;

  void setWarantyOption(String text) {
    selectedWarantyOption = text;
    notifyListeners();
  }

  void setDropFormText(String text) {
    productForm = text;
    notifyListeners();
  }

  void setDropProductTypeText(String text) {
    productType = text;
    notifyListeners();
  }

  void setDropPackageText(String text) {
    productPackage = text;
    notifyListeners();
  }

  void setDropMeasurementText(String text) {
    productMeasurementUnit = text;
    notifyListeners();
  }

  void setIdealForText(String text) {
    idealFor = text;
    notifyListeners();
  }
  /* -------------------------------------------------------------------------- */
  List<String> medicineFormList = [];
  List<String> medicinePackageList = [];
  List<String> equipmentTypeList = [];
  List<String> othersCategoryTypeList = [];
  List<String> othersPackageList = [];
  List<String> othersFormList = [];
// getting the two list The package  and form of medicine
  MedicineData? productFormAndPackage;
  Future<void> getproductFormAndPackageList() async {
    log('CALLED PRODUCT FORM CALLED:::');
    if (medicineFormList.isNotEmpty &&
        medicinePackageList.isNotEmpty &&
        equipmentTypeList.isNotEmpty &&
        othersCategoryTypeList.isNotEmpty &&
        othersPackageList.isNotEmpty &&
        othersFormList.isNotEmpty) return;
    await _iPharmacyFacade.getproductFormAndPackageList().then((value) {
      value.fold((failure) {
        log('ERROR PRODUCT FORM GOT::: ${failure.errMsg}');
        CustomToast.errorToast(text: failure.errMsg);
      }, (data) {
        log('CALLED PRODUCT FORM GOT:::');
        productFormAndPackage = data;
        medicineFormList = productFormAndPackage?.medicineForm ?? [];
        medicinePackageList = productFormAndPackage?.medicinePackage ?? [];
        equipmentTypeList = productFormAndPackage?.equipmentType ?? [];
        othersCategoryTypeList =
            productFormAndPackage?.othersCategoryType ?? [];
        othersPackageList = productFormAndPackage?.othersPackage ?? [];
        othersFormList = productFormAndPackage?.othersForm ?? [];
        notifyListeners();
      });
    });
  }

  /// I.) Medicine section to add
  List<PharmacyProductAddModel> productList = [];
  PharmacyProductAddModel? medicineData;

  Future<void> addPharmacyMedicineDetails({
    required BuildContext context,
  }) async {
    fetchLoading = true;
    notifyListeners();
    medicineProductDetails();
    final result = await _iPharmacyFacade.addPharmacyProductDetails(
        productData: medicineData!,
        productMapData: medicineData!.toMapMedicine());
    result.fold((failure) {
      CustomToast.errorToast(
          text: "Couldn't able to add the medicine, please try again.");
      EasyNavigation.pop(context: context);
    }, (medicineReturned) {
      CustomToast.sucessToast(text: "Added medicine sucessfully");
      clearProductDetails();
      productList.insert(0, medicineReturned);
      notifyListeners();
      EasyNavigation.pop(context: context);
      EasyNavigation.pop(context: context);
    });
    fetchLoading = false;
    notifyListeners();
  }

  List<String> keywordProductNameBuilder() {
    List<String> combinedKeyWords = [];
    combinedKeyWords.addAll(keywordsBuilder(productNameController.text));
    combinedKeyWords.addAll(keywordsBuilder(productBrandNameController.text));
    return combinedKeyWords;
  }

  void medicineProductDetails() {
    
  String? pharmacyId =
      FirebaseAuth.instance.currentUser?.uid;
    medicineData = PharmacyProductAddModel(
      categoryId: categoryId,
      pharmacyId: pharmacyId,
      category: selectedCategoryText,
      productName: productNameController.text,
      productBrandName: productBrandNameController.text,
      productImage: imageProductUrlList,
      typeOfProduct: typeOfProduct,
      productMRPRate: num.tryParse(productMRPController.text),
      productDiscountRate:num.tryParse(productDiscountRateController.text),
      discountPercentage: discountPercentage,
    //  totalQuantity: int.parse(totalQuantityController.text),
      storingDegree: storeBelowController.text,
      idealFor: idealFor,
      expiryDate: Timestamp.fromMillisecondsSinceEpoch(
          expiryDate?.millisecondsSinceEpoch ??
              0), //// want to double check here
      createdAt: Timestamp.now(),
      productFormNumber: int.parse(productFormNumberController.text),
      productForm: productForm,
      productPackageNumber: int.parse(productPackageNumberController.text),
      productPackage: productPackage,
      productMeasurementNumber: int.parse(measurementUnitNumberController.text),
      productMeasurement: productMeasurementUnit,
      productInformation: productInformationController.text,
      keyIngrdients: keyIngredientController.text,
      directionToUse: directionToUseController.text,
      safetyInformation: safetyInformationController.text,
      requirePrescription: prescriptionNeeded,
      inStock: true,
      keyBenefits: keyBenefitController.text,
      keywords: keywordProductNameBuilder(),
    );
    notifyListeners();
  }

  void clearPackageAndFormDetails() {
    log('CALLED PRODUCT FROM CLEAR:::');
    medicineFormList = [];
    medicinePackageList = [];
    equipmentTypeList = [];
    othersCategoryTypeList = [];
    othersPackageList = [];
    othersFormList = [];
    notifyListeners();
  }

  void clearProductDetails() {
    log('CALLED PRODUCT DATA CLEAR:::');
    imageProductUrlList = [];
    typeOfProduct = null;
    productNameController.clear();
    productBrandNameController.clear();
    productMRPController.clear();
    productDiscountRateController.clear();
   // totalQuantityController.clear();
    storeBelowController.clear();
    expiryDateController.clear();
    productFormNumberController.clear();
    productPackageNumberController.clear();
    measurementUnitNumberController.clear();
    keyIngredientController.clear();
    productInformationController.clear();
    directionToUseController.clear();
    safetyInformationController.clear();
    keyBenefitController.clear();
    productWarrantyController.clear();
    productBoxContainsController.clear();
    selectedWarantyOption = null;
    discountAvailable = null;
    prescriptionNeeded = null;
    productForm = null;
    discountPercentage = null;
    productPackage = null;
    productMeasurementUnit = null;
    expiryDate = null;
    idealFor = null;
    productType = null;
    otherData = null;
    medicineData = null;
    equipmentData = null;
    deleteUrlList.clear();
    notifyListeners();
  }

////II.) Equipment section to add
  PharmacyProductAddModel? equipmentData;

  Future<void> addPharmacyEquipmentDetails({
    required BuildContext context,
  }) async {
    fetchLoading = true;
    notifyListeners();
    equipmentProductDetails();
    final result = await _iPharmacyFacade.addPharmacyProductDetails(
        productData: equipmentData!,
        productMapData: equipmentData!.toEquipmentMap());
    result.fold((failure) {
      CustomToast.errorToast(
          text: "Couldn't able to add the equipment, please try again.");
      EasyNavigation.pop(context: context);
    }, (equipmentReturned) {
      CustomToast.sucessToast(text: "Added equipment sucessfully");
      productList.insert(0, equipmentReturned);
      clearProductDetails();
      notifyListeners();
      EasyNavigation.pop(context: context);
      EasyNavigation.pop(context: context);
    });
    fetchLoading = false;
    notifyListeners();
  }

  void equipmentProductDetails() {
    
  String? pharmacyId =
      FirebaseAuth.instance.currentUser?.uid;
    equipmentData = PharmacyProductAddModel(
      categoryId: categoryId,
      pharmacyId: pharmacyId,
      category: selectedCategoryText,
      productName: productNameController.text,
      productBrandName: productBrandNameController.text,
      productImage: imageProductUrlList,
      typeOfProduct: typeOfProduct,
      productMRPRate: num.tryParse(productMRPController.text),
      productDiscountRate: num.tryParse(productDiscountRateController.text),
      discountPercentage: discountPercentage,
   //   totalQuantity: int.parse(totalQuantityController.text),
      productType: productType,
      idealFor: idealFor,
      productBoxContains: productBoxContainsController.text,
      productMeasurementNumber: int.parse(measurementUnitNumberController.text),
      productMeasurement: productMeasurementUnit,
      equipmentWarranty: selectedWarantyOption,
      equipmentWarrantyNumber: num.tryParse(productWarrantyController.text),
      productInformation: productInformationController.text,
      directionToUse: directionToUseController.text,
      safetyInformation: safetyInformationController.text,
      specification: keyBenefitController.text,
      requirePrescription: prescriptionNeeded,
      inStock: true,
      createdAt: Timestamp.now(),
      keywords: keywordProductNameBuilder(),
    );
  }

  /// III.) others  section to add

  PharmacyProductAddModel? otherData;
  Future<void> addPharmacyOthersDetails({
    required BuildContext context,
  }) async {
    fetchLoading = true;
    notifyListeners();
    otherProductDetails();
    final result = await _iPharmacyFacade.addPharmacyProductDetails(
        productData: otherData!, productMapData: otherData!.toMapOther());
    result.fold((failure) {
      CustomToast.errorToast(
          text: "Couldn't able to add the product, please try again.");
      EasyNavigation.pop(context: context);
    }, (otherReturned) {
      CustomToast.sucessToast(text: "Added product sucessfully");
      productList.insert(0, otherReturned);
      clearProductDetails();
      notifyListeners();
      EasyNavigation.pop(context: context);
      EasyNavigation.pop(context: context);
    });
    fetchLoading = false;
    notifyListeners();
  }

  void otherProductDetails() {
    
  String? pharmacyId =
      FirebaseAuth.instance.currentUser?.uid;
    otherData = PharmacyProductAddModel(
      categoryId: categoryId,
      pharmacyId: pharmacyId,
      category: selectedCategoryText,
      productName: productNameController.text,
      productBrandName: productBrandNameController.text,
      productImage: imageProductUrlList,
      typeOfProduct: typeOfProduct,
      productMRPRate: num.tryParse(productMRPController.text),
      productDiscountRate: num.tryParse(productDiscountRateController.text),
      discountPercentage: discountPercentage,
   //   totalQuantity: int.parse(totalQuantityController.text),
      storingDegree: storeBelowController.text,
      idealFor: idealFor,
      productType: productType,
      expiryDate:
          Timestamp.fromMillisecondsSinceEpoch(//// want to double check here
              expiryDate?.millisecondsSinceEpoch ?? 0),
      createdAt: Timestamp.now(),
      productFormNumber: int.parse(productFormNumberController.text),
      productForm: productForm,
      productPackageNumber: int.parse(productPackageNumberController.text),
      productPackage: productPackage,
      productMeasurementNumber: int.parse(measurementUnitNumberController.text),
      productMeasurement: productMeasurementUnit,
      productInformation: productInformationController.text,
      keyIngrdients: keyIngredientController.text,
      directionToUse: directionToUseController.text,
      safetyInformation: safetyInformationController.text,
      inStock: true,
      keyBenefits: keyBenefitController.text,
      keywords: keywordProductNameBuilder(),
    );
    notifyListeners();
  }

//// 2.)  Getting product details according to the category and pharmacy-------

  Future<void> getPharmacyProductDetails({String? searchText}) async {
    
  String? pharmacyId =
      FirebaseAuth.instance.currentUser?.uid;
    fetchLoading = true;
    notifyListeners();
    final result = await _iPharmacyFacade.getPharmacyProductDetails(
        categoryId: categoryId ?? '',
        pharmacyId: pharmacyId ?? '',
        searchText: searchText);
    result.fold((failure) {
      CustomToast.errorToast(text: "Couldn't able to show products");
    }, (products) {
      productList.addAll(products); //// here we are assigning the doctor
    });
    fetchLoading = false;
    notifyListeners();
  }

  void clearFetchData() {
    searchController.clear();
    productList.clear();
    _iPharmacyFacade.clearFetchData();
  }

  final TextEditingController searchController = TextEditingController();
  void searchProduct(String searchText) {
    productList.clear();
    _iPharmacyFacade.clearFetchData();
    getPharmacyProductDetails(searchText: searchText);
    notifyListeners();
  }

// /////// 3.) deleting the doctor field

  Future<void> deletePharmacyProductDetails(
      {required int index,
      required PharmacyProductAddModel productData}) async {
    final result = await _iPharmacyFacade.deletePharmacyProductDetails(
        productId: productData.id ?? '', productData: productData);
    result.fold((failure) {
      CustomToast.errorToast(
          text: "Couldn't able to remove product details, please try again.");
    }, (doctorsData) {
      CustomToast.sucessToast(text: "Removed product sucessfully");
      productList.removeAt(index); //// here we are removing from local list
    });
    notifyListeners();
  }

// /////////////////////////// 3.) update the product field------------------------------
  void setMedicineEditData(
      {required PharmacyProductAddModel medicineEditData}) {
    typeOfProduct = medicineEditData.typeOfProduct;
    imageProductUrlList = medicineEditData.productImage ?? [];
    productNameController.text = medicineEditData.productName ?? '';
    productBrandNameController.text = medicineEditData.productBrandName ?? '';
    productMRPController.text = medicineEditData.productMRPRate.toString();
    discountAvailable = (medicineEditData.productDiscountRate != null);
    productDiscountRateController.text = (medicineEditData.productDiscountRate != null)? medicineEditData.productDiscountRate.toString(): '';
    idealFor = medicineEditData.idealFor;
    discountPercentage = (medicineEditData.discountPercentage != null)
        ? medicineEditData.discountPercentage
        : 0;
   // totalQuantityController.text = medicineEditData.totalQuantity.toString();
    storeBelowController.text = medicineEditData.storingDegree ?? '';
    expiryDateController.text =
        expiryDateSetterFetched(medicineEditData.expiryDate ?? Timestamp.now());
    productFormNumberController.text =
        '${medicineEditData.productFormNumber ?? ''}';
    productForm = medicineEditData.productForm;
    measurementUnitNumberController.text =
        '${medicineEditData.productMeasurementNumber ?? ''}';
    productMeasurementUnit = medicineEditData.productMeasurement;
    productPackageNumberController.text =
        '${medicineEditData.productPackageNumber ?? ''}';
    productPackage = medicineEditData.productPackage;
    keyIngredientController.text = medicineEditData.keyIngrdients ?? '';
    productInformationController.text =
        medicineEditData.productInformation ?? '';
    directionToUseController.text = medicineEditData.directionToUse ?? '';
    safetyInformationController.text = medicineEditData.safetyInformation ?? '';
    keyBenefitController.text = medicineEditData.keyBenefits ?? '';
    prescriptionNeeded = medicineEditData.requirePrescription;
    notifyListeners();
  }

  void setEquipmentEditData(
      {required PharmacyProductAddModel equipmentEditData}) {
    typeOfProduct = equipmentEditData.typeOfProduct;
    imageProductUrlList.addAll(equipmentEditData.productImage ?? []);
    productNameController.text = equipmentEditData.productName ?? '';
    productBrandNameController.text = equipmentEditData.productBrandName ?? '';
    productMRPController.text = equipmentEditData.productMRPRate.toString();
    productDiscountRateController.text =(equipmentEditData.productDiscountRate != null)? equipmentEditData.productDiscountRate.toString(): '';
    discountAvailable = (equipmentEditData.productDiscountRate != null);
    discountPercentage = (equipmentEditData.discountPercentage != null)
        ? equipmentEditData.discountPercentage
        : 0;
  //  totalQuantityController.text = equipmentEditData.totalQuantity.toString();
    productType = equipmentEditData.productType;
    idealFor = equipmentEditData.idealFor;
    productBoxContainsController.text =
        equipmentEditData.productBoxContains ?? '';
    productWarrantyController.text =
        '${equipmentEditData.equipmentWarrantyNumber ?? ''}';
    selectedWarantyOption = equipmentEditData.equipmentWarranty ?? '';
    measurementUnitNumberController.text =
        '${equipmentEditData.productMeasurementNumber ?? ''}';
    productMeasurementUnit = equipmentEditData.productMeasurement;
    productInformationController.text =
        equipmentEditData.productInformation ?? '';
    directionToUseController.text = equipmentEditData.directionToUse ?? '';
    safetyInformationController.text =
        equipmentEditData.safetyInformation ?? '';
    keyBenefitController.text = equipmentEditData.specification ?? '';
    prescriptionNeeded = equipmentEditData.requirePrescription;
    notifyListeners();
  }

  void setOtherEditData({required PharmacyProductAddModel othersEditData}) {
    typeOfProduct = othersEditData.typeOfProduct;
    imageProductUrlList.addAll(othersEditData.productImage ?? []);
    productNameController.text = othersEditData.productName ?? '';
    productBrandNameController.text = othersEditData.productBrandName ?? '';
    productMRPController.text = othersEditData.productMRPRate.toString();
    discountAvailable = (othersEditData.productDiscountRate != null);
    productDiscountRateController.text = (othersEditData.productDiscountRate != null)? othersEditData.productDiscountRate.toString(): '';
    idealFor = othersEditData.idealFor;
    discountPercentage = (othersEditData.discountPercentage != null)
        ? othersEditData.discountPercentage
        : 0;
  //  totalQuantityController.text = othersEditData.totalQuantity.toString();
    expiryDateController.text =
        expiryDateSetterFetched(othersEditData.expiryDate ?? Timestamp.now());
    productFormNumberController.text =
        '${othersEditData.productFormNumber ?? ''}';
    productForm = othersEditData.productForm;
    measurementUnitNumberController.text =
        '${othersEditData.productMeasurementNumber ?? ''}';
    productMeasurementUnit = othersEditData.productMeasurement;
    productPackageNumberController.text =
        '${othersEditData.productPackageNumber ?? ''}';
    productPackage = othersEditData.productPackage;
    productType = othersEditData.productType;
    keyIngredientController.text = othersEditData.keyIngrdients ?? '';
    productInformationController.text = othersEditData.productInformation ?? '';
    directionToUseController.text = othersEditData.directionToUse ?? '';
    safetyInformationController.text = othersEditData.safetyInformation ?? '';
    keyBenefitController.text = othersEditData.keyBenefits ?? '';
    prescriptionNeeded = othersEditData.requirePrescription;

    notifyListeners();
  }

  ///upadting medicine section----------------------------------------------
  ///

  Future<void> updatePharmacyMedicineDetails({
    required int index,
    required PharmacyProductAddModel medicineEditData,
    required BuildContext context,
  }) async {
    fetchLoading = true;
    notifyListeners();
    medicineEditProductDetails(medicineEditData);
    final result = await _iPharmacyFacade.updatePharmacyProductDetails(
        productId: medicineEditData.id ?? '',
        productData: medicineData!,
        productMapData: medicineData!.toMapMedicine());
    result.fold((failure) {
      CustomToast.errorToast(
          text: "Couldn't able to update details, please try again.");
      EasyNavigation.pop(context: context);
    }, (productData) async {
      if (deleteUrlList.isNotEmpty) {
        await deleteProductImageList(imageUrls: deleteUrlList).then((value) {
          deleteUrlList.clear();
        });
      }
      CustomToast.sucessToast(text: "Updated sucessfully");
      productList[index] = productData;
      clearProductDetails(); //// here we are assigning the product
      notifyListeners();
      EasyNavigation.pop(context: context);
      EasyNavigation.pop(context: context);
    });
    fetchLoading = false;
    notifyListeners();
  }

  void medicineEditProductDetails(PharmacyProductAddModel medicineEditData) {
    
  String? pharmacyId =
      FirebaseAuth.instance.currentUser?.uid;
    medicineData = PharmacyProductAddModel(
      id: medicineEditData.id,
      categoryId: categoryId,
      pharmacyId: pharmacyId,
      category: selectedCategoryText,
      productName: productNameController.text,
      productBrandName: productBrandNameController.text,
      productImage: (imageProductUrlList.isEmpty)
          ? medicineEditData.productImage
          : imageProductUrlList,
      typeOfProduct: typeOfProduct,
      productMRPRate: num.tryParse(productMRPController.text),
      productDiscountRate: num.tryParse(productDiscountRateController.text),
      discountPercentage: discountPercentage,
    //  totalQuantity: int.parse(totalQuantityController.text),
      storingDegree: storeBelowController.text,
      idealFor: idealFor,
      expiryDate:
          Timestamp.fromMillisecondsSinceEpoch(//// want to double check here
              expiryDate?.millisecondsSinceEpoch ?? 0),
      createdAt: medicineEditData.createdAt,
      productFormNumber: int.parse(productFormNumberController.text),
      productForm: productForm,
      productPackageNumber: int.parse(productPackageNumberController.text),
      productPackage: productPackage,
      productMeasurementNumber: int.parse(measurementUnitNumberController.text),
      productMeasurement: productMeasurementUnit,
      productInformation: productInformationController.text,
      keyIngrdients: keyIngredientController.text,
      directionToUse: directionToUseController.text,
      safetyInformation: safetyInformationController.text,
      requirePrescription: prescriptionNeeded,
      inStock: true,
      keyBenefits: keyBenefitController.text,
      keywords: keywordProductNameBuilder(),
    );
    notifyListeners();
  }

  ///upadting equipment section----------------------------------------------
  Future<void> updatePharmacyEquipmentDetails({
    required int index,
    required PharmacyProductAddModel equipmentEditData,
    required BuildContext context,
  }) async {
    fetchLoading = true;
    notifyListeners();
    equipmentEditProductDetails(equipmentEditData);
    final result = await _iPharmacyFacade.updatePharmacyProductDetails(
        productId: equipmentEditData.id ?? '',
        productData: equipmentData!,
        productMapData: equipmentData!.toEquipmentMap());
    result.fold((failure) {
      CustomToast.errorToast(
          text: "Couldn't able to update details, please try again.");
      EasyNavigation.pop(context: context);
    }, (productData) async {
      if (deleteUrlList.isNotEmpty) {
        await deleteProductImageList(imageUrls: deleteUrlList).then((value) {
          deleteUrlList.clear();
        });
      }

      productList[index] = productData; //// here we are assigning the product
      CustomToast.sucessToast(text: "Updated sucessfully");
      clearProductDetails();

      notifyListeners();
      EasyNavigation.pop(context: context);
      EasyNavigation.pop(context: context);
    });
    fetchLoading = false;
    notifyListeners();
  }

  void equipmentEditProductDetails(PharmacyProductAddModel equipmentEditData) {
    
  String? pharmacyId =
      FirebaseAuth.instance.currentUser?.uid;
    equipmentData = PharmacyProductAddModel(
      id: equipmentEditData.id,
      categoryId: categoryId,
      pharmacyId: pharmacyId,
      category: selectedCategoryText,
      productName: productNameController.text,
      productBrandName: productBrandNameController.text,
      productImage: (imageProductUrlList.isEmpty)
          ? equipmentEditData.productImage
          : imageProductUrlList,
      typeOfProduct: typeOfProduct,
      productMRPRate: num.tryParse(productMRPController.text),
      productDiscountRate: num.tryParse(productDiscountRateController.text),
      discountPercentage: discountPercentage,
   //   totalQuantity: int.parse(totalQuantityController.text),
      productType: productType,
      idealFor: idealFor,
      productBoxContains: productBoxContainsController.text,
      productMeasurementNumber: int.parse(measurementUnitNumberController.text),
      productMeasurement: productMeasurementUnit,
      equipmentWarranty: selectedWarantyOption,
      equipmentWarrantyNumber: num.tryParse(productWarrantyController.text),
      productInformation: productInformationController.text,
      directionToUse: directionToUseController.text,
      safetyInformation: safetyInformationController.text,
      specification: keyBenefitController.text,
      requirePrescription: prescriptionNeeded,
      inStock: true,
      createdAt: equipmentEditData.createdAt,
      keywords: keywordProductNameBuilder(),
    );
  }

  ///upadting other section----------------------------------------------
  Future<void> updatePharmacyOtherDetails({
    required int index,
    required PharmacyProductAddModel othersEditData,
    required BuildContext context,
  }) async {
    fetchLoading = true;
    notifyListeners();
    otherEditProductDetails(othersEditData);
    final result = await _iPharmacyFacade.updatePharmacyProductDetails(
        productId: othersEditData.id ?? '',
        productData: otherData!,
        productMapData: otherData!.toMapOther());
    result.fold((failure) {
      CustomToast.errorToast(
          text: "Couldn't able to update details, please try again.");
      EasyNavigation.pop(context: context);
    }, (productData) async {
      if (deleteUrlList.isNotEmpty) {
        await deleteProductImageList(imageUrls: deleteUrlList).then((value) {
          deleteUrlList.clear();
        });
      }
      CustomToast.sucessToast(text: "Updated sucessfully");
      productList[index] = productData; //// here we are assigning the product
      clearProductDetails();
      notifyListeners();
      EasyNavigation.pop(context: context);
      EasyNavigation.pop(context: context);
    });
    fetchLoading = false;
    notifyListeners();
  }

  void otherEditProductDetails(PharmacyProductAddModel othersEditData) {
    
  String? pharmacyId =
      FirebaseAuth.instance.currentUser?.uid;
    otherData = PharmacyProductAddModel(
      id: othersEditData.id,
      categoryId: categoryId,
      pharmacyId: pharmacyId,
      category: selectedCategoryText,
      productName: productNameController.text,
      productBrandName: productBrandNameController.text,
      productImage: (imageProductUrlList.isEmpty)
          ? othersEditData.productImage
          : imageProductUrlList,
      typeOfProduct: typeOfProduct,
      productMRPRate: num.tryParse(productMRPController.text),
      productDiscountRate: num.tryParse(productDiscountRateController.text),
      discountPercentage: discountPercentage,
  //    totalQuantity: int.parse(totalQuantityController.text),
      storingDegree: storeBelowController.text,
      idealFor: idealFor,
      productType: productType,
      expiryDate:
          Timestamp.fromMillisecondsSinceEpoch(//// want to double check here
              expiryDate?.millisecondsSinceEpoch ?? 0),
      createdAt: othersEditData.createdAt,
      productFormNumber: int.parse(productFormNumberController.text),
      productForm: productForm,
      productPackageNumber: int.parse(productPackageNumberController.text),
      productPackage: productPackage,
      productMeasurementNumber: int.parse(measurementUnitNumberController.text),
      productMeasurement: productMeasurementUnit,
      productInformation: productInformationController.text,
      keyIngrdients: keyIngredientController.text,
      directionToUse: directionToUseController.text,
      safetyInformation: safetyInformationController.text,
      inStock: true,
      keyBenefits: keyBenefitController.text,
      keywords: keywordProductNameBuilder(),
    );
    notifyListeners();
  }
}
