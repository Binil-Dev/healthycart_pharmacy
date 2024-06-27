// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/domain/model/pharmacy_product_model.dart';

class ProductAndQuantityModel {
  final String? productId;
  final int? quantity;
  final PharmacyProductAddModel? productData;
  ProductAndQuantityModel({
    this.productId,
    this.quantity,
    this.productData,
  });

  ProductAndQuantityModel copyWith({
    String? productId,
    int? quantity,
    Timestamp? createdAt,
    PharmacyProductAddModel? productData,
  }) {
    return ProductAndQuantityModel(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      productData: productData ?? this.productData,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productId': productId,
      'quantity': quantity,
      'productData': productData?.toCartMap(),
    };
  }

  factory ProductAndQuantityModel.fromMap(Map<String, dynamic> map) {
    return ProductAndQuantityModel(
      productId: map['productId'] != null ? map['productId'] as String : null,
      quantity: map['quantity'] != null ? map['quantity'] as int : null,
      productData: map['productData'] != null ? PharmacyProductAddModel.fromMap(map['productData'] as Map<String,dynamic>) : null,
    );
  }

 
}
