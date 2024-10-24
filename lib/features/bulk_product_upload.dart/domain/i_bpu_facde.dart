import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:healthycart_pharmacy/core/general/typdef.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/domain/model/pharmacy_category_model.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/domain/model/product_type_model.dart';

abstract class IBPUFacade {
  FutureResult<List<File>> getProductImageList({required int maxImages});
  FutureResult<List<String>> saveProductImageList({
    required List<File> imageFileList,
  });
  FutureResult<File> getCSVFile();
  FutureResult<String?> saveCSV({
    required File csvFile,
  });

  FutureResult<Unit> deleteImage({
    required String imageUrl,
  });

  FutureResult<List<PharmacyCategoryModel>> getpharmacyCategory({
    required List<String> categoryIdList,
  });

  FutureResult<String> addPharmacyProductDetails({
    required List<Map<String, dynamic>> productListMapData,
  });

  FutureResult<MedicineData> getproductFormAndPackageList();
}
