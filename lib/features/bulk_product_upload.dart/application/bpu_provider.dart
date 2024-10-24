import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthycart_pharmacy/core/custom/keyword_builder/keyword_builder.dart';
import 'package:healthycart_pharmacy/core/custom/toast/toast.dart';
import 'package:healthycart_pharmacy/core/services/easy_navigation.dart';
import 'package:healthycart_pharmacy/features/bulk_product_upload.dart/domain/i_bpu_facde.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/domain/model/pharmacy_category_model.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/domain/model/pharmacy_product_model.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/domain/model/product_type_model.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

@injectable
class BPUProvider extends ChangeNotifier {
  BPUProvider(this._iBPUFacade);
  final IBPUFacade _iBPUFacade;
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

  Future<File?> getCSV({required BuildContext context}) async {
    File? csvFile;
    final result = await _iBPUFacade.getCSVFile();
    result.fold((failure) {
      CustomToast.errorToast(text: failure.errMsg);
      notifyListeners();
    }, (csvSucess) {
      csvFile = csvSucess; // assign the file to the variable
    });
    return csvFile;
  }

  PharmacyCategoryModel? selectedRadioButtonCategoryValue;
  void selectedRadioButton({
    required PharmacyCategoryModel result,
  }) {
    selectedRadioButtonCategoryValue = result;
    notifyListeners();
  }

  List<String> pharmacyCategoryIdList =
      []; // to get id of category from the product list
  List<PharmacyCategoryModel> pharmacyCategoryList = [];

  Future<void> getpharmacyCategory() async {
    if (pharmacyCategoryList.isNotEmpty) return;
    fetchLoading = true;
    notifyListeners();
    final result = await _iBPUFacade.getpharmacyCategory(
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

  String? selectedCategoryText;
  String? categoryId;
  String? typeOfProduct;
  void selectedProductType({String? catId, String? selectedCategory}) {
    selectedCategoryText = selectedCategory;
    categoryId = catId ?? '';
    log(selectedCategory!);
  }

//calculating the discount
  int discountPercentageCalculator({
    required num? productMRPRate,
    required num? productDiscountRate,
  }) {
    num discountRate = productDiscountRate ?? 0;
    num mrp = productMRPRate ?? 0;
    num discountAmount = mrp - discountRate;
    num decimal = discountAmount / mrp;
    return (decimal * 100).toInt();
  }

/////////////////////////////////////////////////////
  List<String> keywordProductNameBuilder({
    required String? productName,
    required String? productBrandName,
  }) {
    List<String> combinedKeyWords = [];
    combinedKeyWords.addAll(keywordsBuilder(productName ?? ''));
    combinedKeyWords.addAll(keywordsBuilder(productBrandName ?? ''));
    return combinedKeyWords;
  }

/* -------------------------------------------------------------------------- */
  Timestamp? parseDateToTimestamp(dynamic dateInput) {
    if (dateInput == null) {
      throw FormatException('Invalid date format $dateInput');
    }

    String dateString = dateInput.toString().trim();

    // Check if the input is numeric (likely an Excel serial date)
    if (_isNumeric(dateString)) {
      int serialDate = int.parse(dateString);
      // Convert the serial date to DateTime
      DateTime date = _excelSerialDateToDateTime(serialDate);
      return Timestamp.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch);
    }

    // Define regex for the two date formats you expect: dd-MM-yyyy and dd/MM/yyyy
    final RegExp format1 = RegExp(r'^\d{2}-\d{2}-\d{4}$'); 
    final RegExp format2 = RegExp(r'^\d{2}/\d{2}/\d{4}$'); 
    final RegExp format3 = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    final RegExp format4 = RegExp(r'^\d{4}/\d{2}/\d{2}$');

    try {
      DateTime parsedDate;

      if (format1.hasMatch(dateString)) {
        // If date matches format dd-MM-yyyy
        parsedDate = DateFormat('dd-MM-yyyy').parse(dateString);
      } else if (format2.hasMatch(dateString)) {
        // If date matches format dd/MM/yyyy
        parsedDate = DateFormat('dd/MM/yyyy').parse(dateString);
      } else if (format3.hasMatch(dateString)) {
        parsedDate = DateFormat('yyyy-MM-dd').parse(dateString);
      } else if (format4.hasMatch(dateString)) {
        parsedDate = DateFormat('yyyy/MM/dd').parse(dateString);
      } else {
        // Handle unrecognized date formats
        log('Invalid date format: $dateString');
        throw FormatException('Invalid date format $dateInput');
      }

      // Convert parsed DateTime to Timestamp
      return Timestamp.fromMillisecondsSinceEpoch(
          parsedDate.millisecondsSinceEpoch);
    } catch (e) {
      throw FormatException('Invalid date format $dateInput');
    }
  }

// Function to check if a string is numeric (for Excel serial date detection)
  bool _isNumeric(String s) {
    if (s.isEmpty) {
      return false;
    }
    return double.tryParse(s) != null;
  }

// Function to convert Excel serial date to DateTime
  DateTime _excelSerialDateToDateTime(int serialDate) {
    // Excel's epoch starts from January 1, 1900 (but mistakenly includes Feb 29, 1900, which wasn't a leap year)
    const excelEpoch =
        25569; // Number of days between 1900-01-01 and Unix epoch (1970-01-01)
    const millisecondsInDay = 86400000; // 24 * 60 * 60 * 1000

    // If the serial date is greater than or equal to 60, we subtract 1 to account for Excel's erroneous leap year
    if (serialDate >= 60) {
      serialDate -= 1;
    }

    // Convert serial date to DateTime
    return DateTime.utc(1970, 1, 1).add(
        Duration(milliseconds: (serialDate - excelEpoch) * millisecondsInDay));
  }

// Timestamp? parseDateToTimestamp(dynamic dateInput) {
//   if (dateInput == null) {
//     return null;
//   }

//   // Convert the input to a string
//   String dateString = dateInput.toString().trim();

//   // Define regex for the two date formats you expect: dd-MM-yyyy and dd/MM/yyyy
//   final RegExp format1 = RegExp(r'^\d{2}-\d{2}-\d{4}$'); // dd-MM-yyyy
//   final RegExp format2 = RegExp(r'^\d{2}/\d{2}/\d{4}$'); // dd/MM/yyyy

//   try {
//     DateTime parsedDate;

//     // Check if the date matches the dd-MM-yyyy format
//     if (format1.hasMatch(dateString)) {
//       parsedDate = DateFormat('dd-MM-yyyy').parse(dateString);
//     }
//     // Check if the date matches the dd/MM/yyyy format
//     else if (format2.hasMatch(dateString)) {
//       parsedDate = DateFormat('dd/MM/yyyy').parse(dateString);
//     }
//     // If the date format doesn't match any known patterns
//     else {
//       throw FormatException('Invalid date format $dateString');

//     }

//     // Convert the parsed DateTime to a Timestamp
//     return Timestamp.fromMillisecondsSinceEpoch(parsedDate.millisecondsSinceEpoch);
//   } catch (e) {
//       throw FormatException('Invalid date format $dateString');
//   }
// }

  // Safely parse and convert fields
  num? productMRPRate;
  num? productDiscountRate;
  String? productName;
  String? productBrandName;
  int? totalQuantity;
  String? cidealFor;
  String? storeBelow;
  String? cproductType;
  int? productFormNumber;
  String? cproductForm;
  int? productMeasurementNumber;
  String? cproductMeasurement;
  int? productPackageNumber;
  String? cproductPackage;
  String? productBoxContains;
  Timestamp? expiryDate;
  num? equipmentWarrantyNumber;
  String? cequipmentWarranty;
  String? productInformation;
  String? keyIngrdients;
  String? directionToUse;
  String? safetyInformation;
  String? keyBenefits;
  String? specification;
  bool? requirePrescription;
  List<PharmacyProductAddModel> validProducts = [];
  List<String> errorMessages = [];
  bool isReadyToUpload = false;
  Future<void> importCSV(File file) async {
    try {
      final input = file.openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n', fieldDelimiter: ','))
          .toList();

      log('$fields');
      log('Number of rows in CSV: ${fields.length}');

      for (int i = 1; i < fields.length; i++) {
        var row = fields[i];
        log('CALED THE ROW$row');

        if (typeOfProduct == 'Medicine') {
          productName = row[0]?.toString();
          productBrandName = row[1]?.toString();
          productMRPRate =
              row[2] != null ? num.tryParse(row[2].toString()) : null;
          productDiscountRate =
              row[3] != null ? num.tryParse(row[3].toString()) : null;

          totalQuantity =
              row[4] != null ? int.tryParse(row[4].toString()) : null;
          storeBelow = row[5]?.toString();
          cidealFor = row[6]?.toString();

          expiryDate = row[7] != null ? parseDateToTimestamp(row[7]) : null;
          productFormNumber =
              row[8] != null ? int.tryParse(row[8].toString()) : null;
          cproductForm = row[9]?.toString();
          productMeasurementNumber =
              row[10] != null ? int.tryParse(row[10].toString()) : null;
          cproductMeasurement = row[11]?.toString();
          productPackageNumber =
              row[12] != null ? int.tryParse(row[12].toString()) : null;
          cproductPackage = row[13]?.toString();
          keyIngrdients = row[14]?.toString();
          productInformation = row[15]?.toString();

          directionToUse = row[16]?.toString();
          safetyInformation = row[17]?.toString();
          keyBenefits = row[18]?.toString();
          requirePrescription =
              row[19] != null ? (row[19].toString() == '1') : false;
        } else if (typeOfProduct == 'Equipment') {
          productName = row[0]?.toString();
          productBrandName = row[1]?.toString();
          productMRPRate =
              row[2] != null ? num.tryParse(row[2].toString()) : null;
          productDiscountRate =
              row[3] != null ? num.tryParse(row[3].toString()) : null;
          totalQuantity =
              row[4] != null ? int.tryParse(row[4].toString()) : null;
          productBoxContains = row[5]?.toString();
          cproductType = row[6]?.toString();
          cidealFor = row[7]?.toString();
          equipmentWarrantyNumber =
              row[8] != null ? num.tryParse(row[8].toString()) : null;
          cequipmentWarranty = row[9]?.toString();

          productMeasurementNumber =
              row[10] != null ? int.tryParse(row[10].toString()) : null;
          cproductMeasurement = row[11]?.toString();

          productInformation = row[12]?.toString();
          directionToUse = row[13]?.toString();
          safetyInformation = row[14]?.toString();
          specification = row[15]?.toString();
          requirePrescription =
              row[16] != null ? (row[16].toString() == '1') : false;
        } else if (typeOfProduct == 'Others') {
          productName = row[0]?.toString();
          productBrandName = row[1]?.toString();
          productMRPRate =
              row[2] != null ? num.tryParse(row[2].toString()) : null;
          productDiscountRate =
              row[3] != null ? num.tryParse(row[3].toString()) : null;

          totalQuantity =
              row[4] != null ? int.tryParse(row[4].toString()) : null;
          expiryDate = row[5] != null ? parseDateToTimestamp(row[5]) : null;
          cproductType = row[6]?.toString();
          cidealFor = row[7]?.toString();
          productFormNumber =
              row[8] != null ? int.tryParse(row[8].toString()) : null;
          cproductForm = row[9]?.toString();
          productMeasurementNumber =
              row[10] != null ? int.tryParse(row[10].toString()) : null;
          cproductMeasurement = row[11]?.toString();
          productPackageNumber =
              row[12] != null ? int.tryParse(row[12].toString()) : null;
          cproductPackage = row[13]?.toString();
          keyIngrdients = row[14]?.toString();
          productInformation = row[15]?.toString();
          directionToUse = row[16]?.toString();
          safetyInformation = row[17]?.toString();
          keyBenefits = row[18]?.toString();
          requirePrescription =
              row[19] != null ? (row[19].toString() == '1') : false;
        }

        // Validate fields and add the product if valid
        bool isValid = validateFields(
          rowIndex: i + 1,
          typeOfProduct: typeOfProduct ?? '',
          productType: cproductType,
          productName: productName,
          productBrandName: productBrandName,
          productMRPRate: productMRPRate,
          productDiscountRate: productDiscountRate,
          totalQuantity: totalQuantity,
          idealFor: cidealFor,
          storingDegree: storeBelow,
          productForm: cproductForm,
          productMeasurement: cproductMeasurement,
          productInformation: productInformation,
          expiryDate: expiryDate,
          productBoxContains: productBoxContains,
          productPackageNumber: productPackageNumber,
          productPackage: cproductPackage,
          productFormNumber: productFormNumber,
          productMeasurementNumber: productMeasurementNumber,
          equipmentWarrantyNumber: equipmentWarrantyNumber,
          equipmentWarranty: cequipmentWarranty,
          keyIngrdients: keyIngrdients,
          directionToUse: directionToUse,
          safetyInformation: safetyInformation,
          keyBenefits: keyBenefits,
          specification: specification,
          requirePrescription: requirePrescription,
          errorMessages: errorMessages,
        );

        if (isValid) {
          PharmacyProductAddModel product = PharmacyProductAddModel(
            pharmacyId: FirebaseAuth.instance.currentUser?.uid ?? '',
            createdAt: Timestamp.now(),
            typeOfProduct: typeOfProduct,
            categoryId: categoryId,
            category: selectedCategoryText,
            keywords: keywordProductNameBuilder(
                productName: productName, productBrandName: productBrandName),
            inStock: false,
            discountPercentage: discountPercentageCalculator(
                productMRPRate: productMRPRate,
                productDiscountRate: productDiscountRate),
            productName: productName,
            productBrandName: productBrandName,
            productMRPRate: productMRPRate,
            productDiscountRate:
                (productDiscountRate != null && productDiscountRate! > 0)
                    ? productDiscountRate
                    : null,
            idealFor: cidealFor,
            totalQuantity: totalQuantity,
            productFormNumber: productFormNumber,
            productForm: cproductForm,
            productMeasurementNumber: productMeasurementNumber,
            productMeasurement: cproductMeasurement,
            productPackageNumber: productPackageNumber,
            productPackage: cproductPackage,
            productInformation: productInformation,
            requirePrescription: requirePrescription,
            expiryDate: expiryDate,
            productBoxContains: productBoxContains,
            safetyInformation: safetyInformation,
            storingDegree: storeBelow,
            keyBenefits: keyBenefits,
            keyIngrdients: keyIngrdients,
            equipmentWarrantyNumber: equipmentWarrantyNumber,
            equipmentWarranty: cequipmentWarranty,
            directionToUse: directionToUse,
            specification: specification,
            productType: cproductType,
          );
          validProducts.add(product);
        }
      }

      // Show validation errors
      if (errorMessages.isEmpty) {
        isReadyToUpload = true;
        notifyListeners();
      } else {
        isReadyToUpload = false;
        notifyListeners();
      }
    } catch (e) {
      log('Error importing CSV file: $e');
      errorMessages.add('Error importing CSV file: ${e.toString()}');

      notifyListeners();
    }
  }

  bool validateFields({
    required int rowIndex,
    required String? typeOfProduct,
    required num? productMRPRate,
    required num? productDiscountRate,
    required String? productName,
    required String? productBrandName,
    int? totalQuantity,
    int? productFormNumber,
    int? productPackageNumber,
    int? productMeasurementNumber,
    num? equipmentWarrantyNumber,
    String? storingDegree,
    String? idealFor,
    Timestamp? expiryDate,
    String? productForm,
    String? productMeasurement,
    String? productInformation,
    String? keyIngrdients,
    String? directionToUse,
    String? safetyInformation,
    String? productBoxContains,
    String? productPackage,
    bool? requirePrescription,
    String? productType,
    String? keyBenefits,
    String? specification,
    String? equipmentWarranty,
    required List<String> errorMessages,
  }) {
    // Check common required fields
    if (productName == null) {
      errorMessages.add('Row $rowIndex: Product Name is missing.');
    }

    if (productBrandName == null) {
      errorMessages.add('Row $rowIndex: Product Brand Name is missing.');
    }
    if (productMRPRate == null) {
      errorMessages.add('Row $rowIndex: MRP Rate is missing.');
    }
    if (productMRPRate == null && productDiscountRate == null) {
      errorMessages.add('Row $rowIndex: Discount Rate is missing.');
    }
    if (idealFor == null) {
      errorMessages.add('Row $rowIndex: ideal for is missing.');
    } else {
      // Trim and check idealFor against idealForOptionList (case-insensitive)
      String trimmedIdealFor = idealFor.trim().toLowerCase();
      bool isValidIdealFor = false;

      for (String option in idealForOptionList) {
        if (trimmedIdealFor == option.toLowerCase()) {
          cidealFor = option; // Assign the standardized value
          isValidIdealFor = true;
          break;
        }
      }

      if (!isValidIdealFor) {
        errorMessages.add(
            'Row $rowIndex: Invalid "ideal for" value "$idealFor" of product $productName.');
      }
    }

    if (productInformation == null) {
      errorMessages.add('Row $rowIndex: product information is missing.');
    }

    if (requirePrescription == null) {
      errorMessages.add('Row $rowIndex: requirePrescription is missing.');
    }
/* -------------------------------------------------------------------------- */
    // Medicine-specific validation
    if (typeOfProduct == 'Medicine' &&
        ((productFormNumber == null && productForm == null) ||
            productForm == null)) {
      errorMessages.add(
          'Row $rowIndex: Medicine-specific product $productName productFormNumber/productForm fields are missing.');
    } else if (typeOfProduct == 'Medicine' && productForm != null) {
      // Trim and check productForm against medicineFormList (case-insensitive)
      String trimmedproductForm = productForm.trim().toLowerCase();
      bool isValidProductForm = false;

      for (String option in medicineFormList) {
        if (trimmedproductForm == option.toLowerCase()) {
          cproductForm = option; // Assign the standardized value
          isValidProductForm = true;
          break;
        }
      }

      if (!isValidProductForm) {
        errorMessages.add(
            'Row $rowIndex: Medicine-specific product $productName,  product form: $productForm is not present in the admin list.');
      }
    }
/* -------------------------------------------------------------------------- */
    if (typeOfProduct == 'Medicine' &&
        (productMeasurement == null || productMeasurementNumber == null)) {
      errorMessages.add(
          'Row $rowIndex: Medicine-specific product  $productName productMeasurement/productMeasurementNumber fields are missing.');
    } else if (typeOfProduct == 'Medicine' && productMeasurement != null) {
      String? standardizedMeasurement =
          getStandardizedMeasurement(productMeasurement, measurmentOptionList);
      if (standardizedMeasurement != null) {
        cproductMeasurement =
            standardizedMeasurement; // Update the productMeasurement with the standardized format
      } else {
        errorMessages.add(
            'Row $rowIndex: Medicine-specific product $productName, Measurement unit "$productMeasurement" is invalid.');
      }
    }
/* -------------------------------------------------------------------------- */
    if (typeOfProduct == 'Medicine' &&
        ((productPackageNumber == null && productPackage == null) ||
            productPackage == null)) {
      errorMessages.add(
          'Row $rowIndex: Medicine-specific  $productName productPackageNumber/productPackage are missing.');
    } else if (typeOfProduct == 'Medicine' && productPackage != null) {
      // Trim and check productForm against medicineFormList (case-insensitive)
      String trimmedproductPackage = productPackage.trim().toLowerCase();
      bool isValidproductPackage = false;

      for (String option in medicinePackageList) {
        if (trimmedproductPackage == option.toLowerCase()) {
          cproductPackage = option; // Assign the standardized value
          isValidproductPackage = true;
          break;
        }
      }

      if (!isValidproductPackage) {
        errorMessages.add(
            'Row $rowIndex: Medicine-specific product $productName,  Product Package: $productPackage is not present in the admin list.');
      }
    }
/* -------------------------------------------------------------------------- */
    if (typeOfProduct == 'Medicine' &&
        (keyIngrdients == null ||
            storingDegree == null ||
            expiryDate == null)) {
      errorMessages.add(
          'Row $rowIndex: Medicine-specific  $productName keyIngrdients/storingDegree/expiryDate are missing.');
    }
    /* -------------------------------------------------------------------------- */
    // Equipment-specific validation
    if (typeOfProduct == 'Equipment' &&
        (equipmentWarrantyNumber == null || equipmentWarranty == null)) {
      errorMessages.add(
          'Row $rowIndex: Equipment-specific  $productName equipmentWarrantyNumber/equipmentWarranty fields are missing.');
    } else if (typeOfProduct == 'Equipment' && equipmentWarranty != null) {
      // Trim and check equipment warranty against the warantyOptionList (case-insensitive)
      String trimmedWarranty = equipmentWarranty.trim().toLowerCase();
      bool isValidWarranty = false;
      for (String option in warantyOptionList) {
        if (trimmedWarranty == option.toLowerCase()) {
          cequipmentWarranty = option; // Assign the standardized value
          isValidWarranty = true;
          break;
        }
      }
      if (!isValidWarranty) {
        errorMessages.add(
            'Row $rowIndex: Invalid warranty "$equipmentWarranty" for $productName.');
      }
    }
    /* -------------------------------------------------------------------------- */
    if (typeOfProduct == 'Equipment' && (productType == null)) {
      errorMessages.add(
          'Row $rowIndex: Equipment-specific  $productName product type are missing.');
    } else if (typeOfProduct == 'Equipment' && productType != null) {
      // Trim and check productType against equipmentTypeList (case-insensitive)
      String trimmedproductType = productType.trim().toLowerCase();
      bool isValidproductType = false;

      for (String option in equipmentTypeList) {
        if (trimmedproductType == option.toLowerCase()) {
          cproductType = option; // Assign the standardized value
          isValidproductType = true;
          break;
        }
      }

      if (!isValidproductType) {
        errorMessages.add(
            'Row $rowIndex: Equipment-specific Product  $productName,   product Type :$productType is not present in the admin list.');
      }
    }
    /* -------------------------------------------------------------------------- */
    if (typeOfProduct == 'Equipment' && (productBoxContains == null)) {
      errorMessages.add(
          'Row $rowIndex: Equipment-specific  $productName productBoxContains field is  missing.');
    }
    /* -------------------------------------------------------------------------- */
    if (typeOfProduct == 'Equipment' &&
        (productMeasurement == null || productMeasurementNumber == null)) {
      errorMessages.add(
          'Row $rowIndex: Equipment-specific  $productName productMeasurement/productMeasurementNumber fields are missing.');
    } else if (typeOfProduct == 'Equipment' && productMeasurement != null) {
      String? standardizedMeasurement =
          getStandardizedMeasurement(productMeasurement, measurmentOptionList);
      /* -------------------------------------------------------------------------- */
      if (standardizedMeasurement != null) {
        cproductMeasurement =
            standardizedMeasurement; // Update the productMeasurement with the standardized format
      } else {
        errorMessages.add(
            'Row $rowIndex: Equipment-specific product $productName, Measurement unit "$productMeasurement"  is invalid.');
      }
    }
/* -------------------------------------------------------------------------- */
    // Others-specific validation
    if (typeOfProduct == 'Others' && (expiryDate == null)) {
      errorMessages.add(
          'Row $rowIndex: Others-specific product: $productName  expiry date field is missing.');
    }
/* -------------------------------------------------------------------------- */
    if (typeOfProduct == 'Others' && (productType == null)) {
      errorMessages.add(
          'Row $rowIndex: Other-specific product  $productName, Product Type : $productType is not found.');
    } else if (typeOfProduct == 'Others' && productType != null) {
      // Trim and check productType against equipmentTypeList (case-insensitive)
      String trimmedproductType = productType.trim().toLowerCase();
      bool isValidproductType = false;

      for (String option in othersCategoryTypeList) {
        if (trimmedproductType == option.toLowerCase()) {
          cproductType = option; // Assign the standardized value
          isValidproductType = true;
          break;
        }
      }

      if (!isValidproductType) {
        errorMessages.add(
            'Row $rowIndex: Others-specific product $productName, Product Type:  $productType is not present in the admin list.');
      }
    }
    /* -------------------------------------------------------------------------- */
    if (typeOfProduct == 'Others' &&
        ((productFormNumber == null && productForm == null) ||
            productForm == null)) {
      errorMessages.add(
          'Row $rowIndex: Others-specific  $productName productFormNumber/productForm fields are missing.');
    } else if (typeOfProduct == 'Others' && productForm != null) {
      // Trim and check productForm against medicineFormList (case-insensitive)
      String trimmedproductForm = productForm.trim().toLowerCase();
      bool isValidproductForm = false;

      for (String option in othersFormList) {
        if (trimmedproductForm == option.toLowerCase()) {
          cproductForm = option; // Assign the standardized value
          isValidproductForm = true;
          break;
        }
      }

      if (!isValidproductForm) {
        errorMessages.add(
            'Row $rowIndex: Others-specific product $productName, Product Form: $productForm is not present in the admin list.');
      }
    }
    /* -------------------------------------------------------------------------- */
    if (typeOfProduct == 'Others' &&
        (productMeasurement == null || productMeasurementNumber == null)) {
      errorMessages.add(
          'Row $rowIndex: Others-specific  $productName product  productMeasurement/productMeasurementNumber fields are missing.');
    } else if (typeOfProduct == 'Others' && productMeasurement != null) {
      String? standardizedMeasurement =
          getStandardizedMeasurement(productMeasurement, measurmentOptionList);
      if (standardizedMeasurement != null) {
        cproductMeasurement =
            standardizedMeasurement; // Update the productMeasurement with the standardized format
      } else {
        errorMessages.add(
            'Row $rowIndex: Others-specific product $productName, Measurement unit "$productMeasurement" is invalid.');
      }
    }
    /* -------------------------------------------------------------------------- */
    if (typeOfProduct == 'Others' &&
        ((productPackageNumber == null && productPackage == null) ||
            productPackage == null)) {
      errorMessages.add(
          'Row $rowIndex: Others-specific  $productName productPackageNumber/productPackage are missing.');
    } else if (typeOfProduct == 'Others' && productPackage != null) {
      // Trim and check productForm against medicineFormList (case-insensitive)
      String trimmedproductPackage = productPackage.trim().toLowerCase();
      bool isValidproductPackage = false;

      for (String option in othersPackageList) {
        if (trimmedproductPackage == option.toLowerCase()) {
          cproductPackage = option; // Assign the standardized value
          isValidproductPackage = true;
          break;
        }
      }

      if (!isValidproductPackage) {
        errorMessages.add(
            'Row $rowIndex: Others-specific product $productName, Product Package  $productPackage is not present in the admin list.');
      }
    }
    /* -------------------------------------------------------------------------- */
    if (typeOfProduct == 'Others' && (keyIngrdients == null)) {
      errorMessages.add(
          'Row $rowIndex: Others-specific  $productName keyIngrdients are missing.');
    }
    log('CALLED HERE');
    notifyListeners();
    return errorMessages.isEmpty;
  }

  Future<void> addPharmacyProductDetails({
    required BuildContext context,
  }) async {
    List<Map<String, dynamic>>? productListMapData;
    if (typeOfProduct == 'Medicine') {
      productListMapData = validProducts
          .map(
            (e) => e.toMapMedicine(),
          )
          .toList();
    } else if (typeOfProduct == 'Equipment') {
      productListMapData = validProducts
          .map(
            (e) => e.toEquipmentMap(),
          )
          .toList();
    } else if (typeOfProduct == 'Others') {
      productListMapData = validProducts
          .map(
            (e) => e.toMapOther(),
          )
          .toList();
    }
    if (productListMapData != null) {
      final result = await _iBPUFacade.addPharmacyProductDetails(
          productListMapData: productListMapData);
      result.fold((failure) {
        CustomToast.errorToast(
            text: "Couldn't able to add the products, please try again.");
        EasyNavigation.pop(context: context);
      }, (sucess) {
        CustomToast.sucessToast(text: sucess);
        EasyNavigation.pop(context: context);
        validProducts.clear();
        isReadyToUpload = false;
      });
      notifyListeners();
    } else {
      CustomToast.errorToast(text: "An error occurred, please try again.");
      EasyNavigation.pop(context: context);
    }
  }

// Function to check if a measurement matches any in the list and return standardized format
  String? getStandardizedMeasurement(
      String productMeasurement, List<String> measurmentOptionList) {
    String trimmedMeasurement = productMeasurement.trim().toLowerCase();

    for (String option in measurmentOptionList) {
      // Split the option into unit and description (e.g., 'mg (Milligram)')
      List<String> splitOption = option.split(' ');
      String unit = splitOption[0];
      // Remove any parentheses and get only the description
      String description = splitOption[1].replaceAll(RegExp(r'[()]'), '');

      // Check if the trimmed measurement contains either the unit or description
      if (trimmedMeasurement.contains(unit.toLowerCase()) ||
          trimmedMeasurement.contains(description.toLowerCase())) {
        return option; // Return the standardized format, e.g., 'mg (Milligram)'
      }
    }

    return null; // Return null if no match is found
  }

/* -------------------------------------------------------------------------- */
  List<String> measurmentOptionList = [
    'L (Litre)',
    'mL (Millilitre)',
    'cc (Cubic cm)',
    'Kg (Kilogram)',
    'g (Gram)',
    'mg (Milligram)',
    'µg (Microgram)',
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
    await _iBPUFacade.getproductFormAndPackageList().then((value) {
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
// Function to import Excel
  // Future<void> importExcel(File file) async {
  //   try {
  //     var bytes = file.readAsBytesSync();
  //     log('$bytes');
  //     var excel = Excel.decodeBytes(bytes.toList());

  //     for (var table in excel.tables.keys) {
  //       var sheet = excel.tables[table];
  //       if (sheet != null) {
  //         for (int i = 1; i < sheet.rows.length; i++) {
  //           var row = sheet.rows[i];

  //           // Extract and validate each field (adjust indices as per Excel sheet columns)
  //           num? productMRPRate = row[0]?.value;
  //           num? productDiscountRate = row[1]?.value;
  //           String? productName = row[2]?.value;
  //           String? productBrandName = row[3]?.value;
  //           int? totalQuantity = row[4]?.value;
  //           String? idealFor = row[5]?.value;
  //           String? productType = row[6]?.value;
  //           String? productForm = row[7]?.value;
  //           int? productFormNumber = row[8]?.value;
  //           String? productMeasurement = row[9]?.value;
  //           int? productMeasurementNumber = row[10]?.value;
  //           int? productPackageNumber = row[11]?.value;
  //           String? productPackage = row[12]?.value;
  //           String? productBoxContains = row[13]?.value;
  //           Timestamp? expiryDate = row[14]?.value != null
  //               ? Timestamp.fromDate(DateTime.parse(row[14]?.value))
  //               : null;
  //           num? equipmentWarrantyNumber = row[15]?.value;
  //           String? equipmentWarranty = row[16]?.value;
  //           String? productInformation = row[17]?.value;
  //           String? keyIngrdients = row[18]?.value;
  //           String? directionToUse = row[19]?.value;
  //           String? safetyInformation = row[20]?.value;
  //           String? keyBenefits = row[21]?.value;
  //           bool? requirePrescription = row[22]?.value;

  //           // Validate fields based on type (Medicine, Equipment, or Others)
  //           bool isValid = validateFields(
  //             rowIndex: i + 1,
  //             typeOfProduct: typeOfProduct ?? '',
  //             productType: productType,
  //             productName: productName,
  //             productBrandName: productBrandName,
  //             productMRPRate: productMRPRate,
  //             productDiscountRate: productDiscountRate,
  //             totalQuantity: totalQuantity,
  //             idealFor: idealFor,
  //             productForm: productForm,
  //             productMeasurement: productMeasurement,
  //             productInformation: productInformation,
  //             expiryDate: expiryDate,
  //             productBoxContains: productBoxContains,
  //             productPackageNumber: productPackageNumber,
  //             productPackage: productPackage,
  //             productFormNumber: productFormNumber,
  //             productMeasurementNumber: productMeasurementNumber,
  //             equipmentWarrantyNumber: equipmentWarrantyNumber,
  //             equipmentWarranty: equipmentWarranty,
  //             keyIngrdients: keyIngrdients,
  //             directionToUse: directionToUse,
  //             safetyInformation: safetyInformation,
  //             keyBenefits: keyBenefits,
  //             requirePrescription: requirePrescription,
  //             errorMessages: errorMessages,
  //           );

  //           // Create PharmacyProductAddModel if valid
  //           if (isValid) {
  //             PharmacyProductAddModel product = PharmacyProductAddModel(
  //               pharmacyId: FirebaseAuth.instance.currentUser?.uid ?? '',
  //               typeOfProduct: typeOfProduct,
  //               categoryId: categoryId,
  //               category: selectedCategoryText,
  //               keywords: keywordProductNameBuilder(
  //                   productName: productName,
  //                   productBrandName: productBrandName),
  //               inStock: false,
  //               discountPercentage: discountPercentageCalculator(
  //                   productMRPRate: productMRPRate,
  //                   productDiscountRate: productDiscountRate),
  //               productName: productName,
  //               productBrandName: productBrandName,
  //               productMRPRate: productMRPRate,
  //               productDiscountRate: productDiscountRate,
  //               totalQuantity: totalQuantity,
  //               productFormNumber: productFormNumber,
  //               productForm: productForm,
  //               productMeasurementNumber: productMeasurementNumber,
  //               productMeasurement: productMeasurement,
  //               productPackageNumber: productPackageNumber,
  //               productPackage: productPackage,
  //               productInformation: productInformation,
  //               requirePrescription: requirePrescription,
  //               expiryDate: expiryDate,
  //               productBoxContains: productBoxContains,
  //               productType: productType,
  //             );
  //             validProducts.add(product);
  //           }
  //         }
  //       }
  //     }

  //     // Show error messages if there are invalid products
  //     if (errorMessages.isNotEmpty) {
  //       showValidationErrors(errorMessages);
  //       notifyListeners();
  //     } else {}
  //   } catch (e) {
  //     // Handle errors during file reading and processing
  //     print('Error importing Excel file: $e');
  //     errorMessages.add('Error importing Excel file: ${e.toString()}');
  //     showValidationErrors(errorMessages);
  //     notifyListeners();
  //   }
  // }

// Validation function with error handling
}
