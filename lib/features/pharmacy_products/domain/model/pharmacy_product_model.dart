import 'package:cloud_firestore/cloud_firestore.dart';

class PharmacyProductAddModel {
  String? id;
  final String? pharmacyId;
  final String? categoryId;
  final String? category;
  final String? typeOfProduct;
  final num? productMRPRate;
  final num? productDiscountRate;
  final int? discountPercentage;
  final List<String>? productImage;
  final String? productName;
  final String? productBrandName;
  final int? totalQuantity;
  final int? productFormNumber;
  final int? productPackageNumber;
  final int? productMeasurementNumber;
  final num? equipmentWarrantyNumber;
  final String? storingDegree;
  final String? idealFor;
  final Timestamp? expiryDate;
  final Timestamp? createdAt;
  final String? productForm;
  final String? productMeasurement;
  final String? productInformation;
  final String? keyIngrdients;
  final String? directionToUse;
  final String? safetyInformation;
  final String? productBoxContains;
  final String? productPackage;
  final bool? requirePrescription;
  final bool? inStock;
  final String? productType;
  final String? keyBenefits;
  final String? specification;
  final String? equipmentWarranty;
  final List<String>? keywords;
  PharmacyProductAddModel({
    this.id,
    this.pharmacyId,
    this.categoryId,
    this.category,
    this.typeOfProduct,
    this.productMRPRate,
    this.productDiscountRate,
    this.discountPercentage,
    this.productImage,
    this.productName,
    this.productBrandName,
    this.totalQuantity,
    this.productFormNumber,
    this.productPackageNumber,
    this.productMeasurementNumber,
    this.equipmentWarrantyNumber,
     this.storingDegree,
    this.idealFor,
    this.expiryDate,
    this.createdAt,
    this.productForm,
    this.productMeasurement,
    this.productInformation,
    this.keyIngrdients,
    this.directionToUse,
    this.safetyInformation,
    this.productBoxContains,
    this.productPackage,
    this.requirePrescription,
     this.inStock,
    this.productType,
    this.keyBenefits,
    this.specification,
    this.equipmentWarranty,
    this.keywords,
  });

  PharmacyProductAddModel copyWith({
    String? id,
    String? pharmacyId,
    String? categoryId,
    String? category,
    String? typeOfProduct,
    num? productMRPRate,
    num? productDiscountRate,
    int? discountPercentage,
    List<String>? productImage,
    String? productName,
    String? productBrandName,
    int? totalQuantity,
    int? productFormNumber,
    int? productPackageNumber,
    int? productMeasurementNumber,
    num? equipmentWarrantyNumber,
    String? storingDegree,
    String? idealFor,
    Timestamp? expiryDate,
    Timestamp? createdAt,
    String? productForm,
    String? productMeasurement,
    String? productInformation,
    String? keyIngrdients,
    String? directionToUse,
    String? safetyInformation,
    String? productBoxContains,
    String? productPackage,//// want to change
    bool? requirePrescription,
     bool? inStock,
    String? productType,
    String? keyBenefits,
    String? specification,
    String? equipmentWarranty,
    List<String>? keywords,
  }) {
    return PharmacyProductAddModel(
      id: id ?? this.id,
      pharmacyId: pharmacyId ?? this.pharmacyId,
      categoryId: categoryId ?? this.categoryId,
       category: category ?? this.category,
      typeOfProduct: typeOfProduct ?? this.typeOfProduct,
      productMRPRate: productMRPRate ?? this.productMRPRate,
      productDiscountRate: productDiscountRate ?? this.productDiscountRate,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      productImage: productImage ?? this.productImage,
      productName: productName ?? this.productName,
      productBrandName: productBrandName ?? this.productBrandName,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      productFormNumber: productFormNumber ?? this.productFormNumber,
      productPackageNumber: productPackageNumber ?? this.productPackageNumber,
      productMeasurementNumber: productMeasurementNumber ?? this.productMeasurementNumber,
      equipmentWarrantyNumber: equipmentWarrantyNumber ?? this.equipmentWarrantyNumber,
      storingDegree: storingDegree ?? this.storingDegree,
      idealFor: idealFor ?? this.idealFor,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      productForm: productForm ?? this.productForm,
      productMeasurement: productMeasurement ?? this.productMeasurement,
      productInformation: productInformation ?? this.productInformation,
      keyIngrdients: keyIngrdients ?? this.keyIngrdients,
      directionToUse: directionToUse ?? this.directionToUse,
      safetyInformation: safetyInformation ?? this.safetyInformation,
      productBoxContains: productBoxContains ?? this.productBoxContains,
      productPackage: productPackage ?? this.productPackage,
      requirePrescription: requirePrescription ?? this.requirePrescription,
      inStock: inStock ?? this.inStock,
      productType: productType ?? this.productType,
      keyBenefits: keyBenefits ?? this.keyBenefits,
      specification: specification ?? this.specification,
      equipmentWarranty: equipmentWarranty ?? this.equipmentWarranty,
      keywords: keywords ?? this.keywords,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'pharmacyId': pharmacyId,
      'categoryId': categoryId,
      'category': category,
      'typeOfProduct': typeOfProduct,
      'productMRPRate': productMRPRate,
      'productDiscountRate': productDiscountRate,
      'discountPercentage': discountPercentage,
      'productImage': productImage,
      'productName': productName,
      'productBrandName': productBrandName,
      'totalQuantity': totalQuantity,
      'productFormNumber': productFormNumber,
      'productPackageNumber': productPackageNumber,
      'productMeasurementNumber': productMeasurementNumber,
      'equipmentWarrantyNumber': equipmentWarrantyNumber,
      'storingDegree': storingDegree,
      'idealFor': idealFor,
      'expiryDate': expiryDate,
      'createdAt': createdAt,
      'productForm': productForm,
      'productMeasurement': productMeasurement,
      'productInformation': productInformation,
      'keyIngrdients': keyIngrdients,
      'directionToUse': directionToUse,
      'safetyInformation': safetyInformation,
      'productBoxContains': productBoxContains,
      'productPackage': productPackage,
      'requirePrescription': requirePrescription,
      'inStock': inStock,
      'productType': productType,
      'keyBenefits': keyBenefits,
      'specification': specification,
      'equipmentWarranty': equipmentWarranty,
      'keywords': keywords,
    };
  }
  
   Map<String, dynamic> toCartMap() {
    return <String, dynamic>{
      'id': id,
      'pharmacyId': pharmacyId,
      'categoryId': categoryId,
      'category': category,
      'typeOfProduct': typeOfProduct,
      'productMRPRate': productMRPRate,
      'productDiscountRate': productDiscountRate,
      'discountPercentage': discountPercentage,
      'productImage': productImage,
      'productName': productName,
      'productBrandName': productBrandName,
      'productFormNumber': productFormNumber,
      'productPackageNumber': productPackageNumber,
      'productMeasurementNumber': productMeasurementNumber,
      'productMeasurement': productMeasurement,
      'productForm': productForm,
       'productPackage': productPackage,
        'productType': productType,
    };
  }
  Map<String, dynamic> toEquipmentMap() {
    return <String, dynamic>{
      'id': id,
      'pharmacyId': pharmacyId,
      'categoryId': categoryId,
      'category': category,
      'typeOfProduct': typeOfProduct,
      'productMRPRate': productMRPRate,
      'productDiscountRate': productDiscountRate,
      'discountPercentage': discountPercentage,
      'productImage': productImage,
      'productName': productName,
      'productBrandName': productBrandName,
      'totalQuantity': totalQuantity,
      'productMeasurementNumber': productMeasurementNumber,
      'equipmentWarrantyNumber': equipmentWarrantyNumber,
      'createdAt': createdAt,
      'idealFor': idealFor,
      'productInformation': productInformation,
      'directionToUse': directionToUse,
      'safetyInformation': safetyInformation,
      'productBoxContains': productBoxContains,
      'productMeasurement': productMeasurement,
      'requirePrescription': requirePrescription,
      'inStock': inStock,
      'productType': productType,
      'specification': specification,
      'equipmentWarranty': equipmentWarranty,
      'keywords': keywords,
    };
  }
  Map<String, dynamic> toMapMedicine() {
    return <String, dynamic>{
      'id': id,
      'pharmacyId': pharmacyId,
      'categoryId': categoryId,
      'category': category,
      'typeOfProduct': typeOfProduct,
      'productMRPRate': productMRPRate,
      'productDiscountRate': productDiscountRate,
      'discountPercentage': discountPercentage,
      'productImage': productImage,
      'productName': productName,
      'productBrandName': productBrandName,
      'totalQuantity': totalQuantity,
      'productFormNumber': productFormNumber,
      'productPackageNumber': productPackageNumber,
      'productMeasurementNumber': productMeasurementNumber,
      'storingDegree': storingDegree,
      'idealFor': idealFor,
      'expiryDate': expiryDate,
      'createdAt': createdAt,
      'productForm': productForm,
      'productMeasurement': productMeasurement,
      'productPackage': productPackage,
      'productInformation': productInformation,
      'keyIngrdients': keyIngrdients,
      'directionToUse': directionToUse,
      'safetyInformation': safetyInformation,
      'requirePrescription': requirePrescription,
      'inStock': inStock,
      'keyBenefits': keyBenefits,
      'keywords': keywords,
    };
  }
    Map<String, dynamic> toMapOther() {
    return <String, dynamic>{
      'id': id,
      'pharmacyId': pharmacyId,
      'categoryId': categoryId,
      'category': category,
      'typeOfProduct': typeOfProduct,
      'productMRPRate': productMRPRate,
      'productDiscountRate': productDiscountRate,
      'discountPercentage': discountPercentage,
      'productImage': productImage,
      'productName': productName,
      'productBrandName': productBrandName,
      'totalQuantity': totalQuantity,
      'productType': productType,
      'productFormNumber': productFormNumber,
      'productPackageNumber': productPackageNumber,
      'productMeasurementNumber': productMeasurementNumber,
      'idealFor': idealFor,
      'expiryDate': expiryDate,
      'createdAt': createdAt,
      'productForm': productForm,
      'productMeasurement': productMeasurement,
      'productInformation': productInformation,
      'inStock': inStock,
      'productPackage': productPackage,
      'keyIngrdients': keyIngrdients,
      'directionToUse': directionToUse,
      'safetyInformation': safetyInformation,
      'keyBenefits': keyBenefits,
      'keywords': keywords,
    };
  }

  factory PharmacyProductAddModel.fromMap(Map<String, dynamic> map) {
    return PharmacyProductAddModel(
      id: map['id'] != null ? map['id'] as String : null,
      pharmacyId:
          map['pharmacyId'] != null ? map['pharmacyId'] as String : null,
      categoryId:
          map['categoryId'] != null ? map['categoryId'] as String : null,
      category:
          map['category'] != null ? map['category'] as String : null,     
      typeOfProduct:
          map['typeOfProduct'] != null ? map['typeOfProduct'] as String : null,
      productMRPRate:
          map['productMRPRate'] != null ? map['productMRPRate'] as num : null,
      productDiscountRate: map['productDiscountRate'] != null
          ? map['productDiscountRate'] as num
          : null,
      discountPercentage: map['discountPercentage'] != null
          ? map['discountPercentage'] as int
          : null,
      productImage: map['productImage'] != null
          ? List<String>.from((map['productImage'] as List<dynamic>))
          : null,
      productName:
          map['productName'] != null ? map['productName'] as String : null,
      productBrandName: map['productBrandName'] != null
          ? map['productBrandName'] as String
          : null,
      productFormNumber:
          map['productFormNumber'] != null ? map['productFormNumber'] as int : null,
       totalQuantity:
          map['totalQuantity'] != null ? map['totalQuantity'] as int : null,
        productPackageNumber:
          map['productPackageNumber'] != null ? map['productPackageNumber'] as int : null,
         productMeasurementNumber:
          map['productMeasurementNumber'] != null ? map['productMeasurementNumber'] as int : null,
         equipmentWarrantyNumber:
          map['equipmentWarrantyNumber'] != null ? map['equipmentWarrantyNumber'] as num : null,           
      storingDegree:
          map['storingDegree'] != null ? map['storingDegree'] as String : null,
      idealFor:
          map['idealFor'] != null ? map['idealFor'] as String : null,    
      expiryDate:
          map['expiryDate'] != null ? (map['expiryDate'] as Timestamp) : null,
      createdAt:
          map['createdAt'] != null ? (map['createdAt'] as Timestamp) : null,
      productForm:
          map['productForm'] != null ? map['productForm'] as String : null,
      productMeasurement: map['productMeasurement'] != null
          ? map['productMeasurement'] as String
          : null,
      productInformation: map['productInformation'] != null
          ? map['productInformation'] as String
          : null,
      keyIngrdients:
          map['keyIngrdients'] != null ? map['keyIngrdients'] as String : null,
      directionToUse: map['directionToUse'] != null
          ? map['directionToUse'] as String
          : null,
      safetyInformation: map['safetyInformation'] != null
          ? map['safetyInformation'] as String
          : null,
      productBoxContains: map['productBoxContains'] != null
          ? map['productBoxContains'] as String
          : null,
      productPackage: map['productPackage'] != null
          ? map['productPackage'] as String
          : null,
      requirePrescription: map['requirePrescription'] != null
          ? map['requirePrescription'] as bool
          : null,
       inStock: map['inStock'] != null
          ? map['inStock'] as bool
          : null,    
      productType:
          map['productType'] != null ? map['productType'] as String : null,
      keyBenefits:
          map['keyBenefits'] != null ? map['keyBenefits'] as String : null,
      specification:
          map['specification'] != null ? map['specification'] as String : null,
      equipmentWarranty:
          map['equipmentWarranty'] != null ? map['equipmentWarranty'] as String : null,
      keywords: map['keywords'] != null
          ? List<String>.from((map['keywords'] as List<dynamic>))
          : null,
    );
  }
}
