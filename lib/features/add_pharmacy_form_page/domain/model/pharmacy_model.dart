

import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:healthycart_pharmacy/features/location_picker/domain/model/location_model.dart';

class PharmacyModel {
  String? id;
  final String? phoneNo;
  PlaceMark? placemark;
  final String? pharmacyName;
  final String? pharmacyAddress;
  final String? pharmacyownerName;
  final String? pharmacyDocumentLicense;
  final String? pharmacyImage;
  final int? pharmacyRequested;
  final bool? isActive;
  final bool? isPharmacyON;
  final Timestamp? createdAt;
  final List<String>? selectedCategoryId;
  final List<String>? pharmacyKeywords;
  final String? rejectionReason;
  PharmacyModel({
    this.id,
    this.phoneNo,
    this.placemark,
    this.pharmacyName,
    this.pharmacyAddress,
    this.pharmacyownerName,
    this.pharmacyDocumentLicense,
    this.pharmacyImage,
    this.pharmacyRequested,
    this.isActive,
    this.isPharmacyON,
    this.createdAt,
    this.selectedCategoryId,
    this.pharmacyKeywords,
    this.rejectionReason,
  });

  PharmacyModel copyWith({
    String? id,
    String? phoneNo,
    PlaceMark? placemark,
    String? pharmacyName,
    String? pharmacyAddress,
    String? pharmacyownerName,
    String? pharmacyDocumentLicense,
    String? pharmacyImage,
    List<String>? selectedCategoryId,
    int? pharmacyRequested,
    bool? isActive,
    bool? isPharmacyON,
    Timestamp? createdAt,
    List<String>? pharmacyKeywords,
    String? rejectionReason,
  }) {
    return PharmacyModel(
      id: id ?? this.id,
      phoneNo: phoneNo ?? this.phoneNo,
      placemark: placemark ?? this.placemark,
      pharmacyName: pharmacyName ?? this.pharmacyName,
      pharmacyAddress: pharmacyAddress ?? this.pharmacyAddress,
      pharmacyownerName: pharmacyownerName ?? this.pharmacyownerName,
      pharmacyDocumentLicense: pharmacyDocumentLicense ?? this.pharmacyDocumentLicense,
      pharmacyImage: pharmacyImage ?? this.pharmacyImage,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      pharmacyRequested: pharmacyRequested ?? this.pharmacyRequested,
      isActive: isActive ?? this.isActive,
      isPharmacyON: isPharmacyON ?? this.isPharmacyON,
      createdAt: createdAt ?? this.createdAt,
      pharmacyKeywords: pharmacyKeywords ?? this.pharmacyKeywords,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'phoneNo': phoneNo,
      'placemark': placemark?.toMap(),
      'pharmacyName': pharmacyName,
      'pharmacyAddress': pharmacyAddress,
      'pharmacyownerName': pharmacyownerName,
      'pharmacyDocumentLicense': pharmacyDocumentLicense,
      'pharmacyImage': pharmacyImage,
      'selectedCategoryId': selectedCategoryId,
      'pharmacyRequested': pharmacyRequested,
      'isActive': isActive,
      'isPharmacyON': isPharmacyON,
      'createdAt': createdAt,
      'pharmacyKeywords': pharmacyKeywords,
      'rejectionReason': rejectionReason,
    };
  }
  
  Map<String, dynamic> toEditMap() {
    return <String, dynamic>{ 
      'pharmacyName': pharmacyName,
      'pharmacyAddress': pharmacyAddress,
      'pharmacyownerName': pharmacyownerName,
      'pharmacyDocumentLicense': pharmacyDocumentLicense,
      'pharmacyImage': pharmacyImage,
      'pharmacyKeywords': pharmacyKeywords,
    };
  }

  factory PharmacyModel.fromMap(Map<String, dynamic> map) {
    return PharmacyModel(
      id: map['id'] != null ? map['id'] as String : null,
      phoneNo: map['phoneNo'] != null ? map['phoneNo'] as String : null,
      placemark: map['placemark'] != null ? PlaceMark.fromMap(map['placemark'] as Map<String,dynamic>) : null,
      pharmacyName: map['pharmacyName'] != null ? map['pharmacyName'] as String : null,
      pharmacyAddress: map['pharmacyAddress'] != null ? map['pharmacyAddress'] as String : null,
      pharmacyownerName: map['pharmacyownerName'] != null ? map['pharmacyownerName'] as String : null,
      pharmacyDocumentLicense: map['pharmacyDocumentLicense'] != null ? map['pharmacyDocumentLicense'] as String : null,
      pharmacyImage: map['pharmacyImage'] != null ? map['pharmacyImage'] as String : null,
      selectedCategoryId: map['selectedCategoryId'] != null ? List<String>.from((map['selectedCategoryId'] as List<dynamic>)) : null,
      pharmacyRequested: map['pharmacyRequested'] != null ? map['pharmacyRequested'] as int : null,
      isActive: map['isActive'] != null ? map['isActive'] as bool : null,
      isPharmacyON: map['isPharmacyON'] != null ? map['isPharmacyON'] as bool : null,
      createdAt: map['createdAt'] != null ? map['createdAt'] as Timestamp : null,
      pharmacyKeywords: map['pharmacyKeywords'] != null ? List<String>.from((map['pharmacyKeywords'] as List<dynamic>)) : null,
      rejectionReason: map['rejectionReason'] != null ? map['rejectionReason'] as String : null,
    );
  }

}
