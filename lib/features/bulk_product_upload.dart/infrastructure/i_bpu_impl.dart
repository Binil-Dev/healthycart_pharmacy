import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:healthycart_pharmacy/core/failures/main_failure.dart';
import 'package:healthycart_pharmacy/core/general/firebase_collection.dart';
import 'package:healthycart_pharmacy/core/general/typdef.dart';
import 'package:healthycart_pharmacy/core/services/excel_file_servce.dart';
import 'package:healthycart_pharmacy/core/services/image_picker.dart';
import 'package:healthycart_pharmacy/features/bulk_product_upload.dart/domain/i_bpu_facde.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/domain/model/pharmacy_category_model.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/domain/model/pharmacy_product_model.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/domain/model/product_type_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IBPUFacade)
class IBPUImpl implements IBPUFacade {
  IBPUImpl(this._firebaseFirestore, this._imageService, this._excelService);
  final FirebaseFirestore _firebaseFirestore;
  final ImageService _imageService;
  final CSVFileService _excelService;

     @override
  FutureResult<File> getCSVFile() async {
    return await _excelService.getCSVFile();
  }

  @override
  FutureResult<String?> saveCSV({
    required File csvFile,
  }) async {
    return await _excelService.uploadCSV(csvFile: csvFile);
  }

  // @override
  // FutureResult<String?> deleteExcel({
  //   required String pharmacyId,
  //   required String excelUrl,
  // }) async {
  //   try {
  //     await _excelService.deleteExcelUrl(url: excelUrl).then((value) {
  //       value.fold((failure) {
  //         return left(failure);
  //       }, (sucess) async {
  //         await _firebaseFirestore
  //             .collection(FirebaseCollections.pharmacy)
  //             .doc(pharmacyId)
  //             .update({'pharmacyDocumentLicense': null}).then((value) {});
  //       });
  //     });
  //     return right('Sucessfully removed');
  //   } catch (e) {
  //     return left(MainFailure.generalException(errMsg: e.toString()));
  //   }
  // }

  @override
  FutureResult<List<File>> getProductImageList({required int maxImages}) async {
    return await _imageService.getMultipleGalleryImage(maxImages: maxImages);
  }



  @override
  FutureResult<List<String>> saveProductImageList(
      {required List<File> imageFileList}) async {
    List<String> imageUrlList = [];
    for (var imageFile in imageFileList) {
      await _imageService
          .saveImage(imageFile: imageFile, folderName: 'pharmacy_product')
          .then((result) {
        result.fold((failure) {
          return left(failure);
        }, (imageUrl) {
          imageUrlList.add(imageUrl);
        });
      });
    }
    return right(imageUrlList);
  }

  @override
  FutureResult<Unit> deleteImage({required String imageUrl}) async {
    return await _imageService.deleteImageUrl(imageUrl: imageUrl);
  }



//////////////// getting the list of pharmacy selected categories here
  @override
  FutureResult<List<PharmacyCategoryModel>> getpharmacyCategory(
      {required List<String> categoryIdList}) async {
    try {
      List<Future<DocumentSnapshot<Map<String, dynamic>>>> futures = [];

      for (var element in categoryIdList) {
        futures.add(_firebaseFirestore
            .collection(FirebaseCollections.pharmacycategory)
            .doc(element)
            .get());
      }

      List<DocumentSnapshot<Map<String, dynamic>>> results =
          await Future.wait<DocumentSnapshot<Map<String, dynamic>>>(futures);

      final categoryList = results
          .map<PharmacyCategoryModel>((e) =>
              PharmacyCategoryModel.fromMap(e.data() as Map<String, dynamic>)
                  .copyWith(id: e.id))
          .toList();

      return right(categoryList);
    } on FirebaseException catch (e) {
      log(e.toString());
      return left(MainFailure.firebaseException(errMsg: e.message.toString()));
    } catch (e) {
      log(e.toString());

      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }



  //////////////////////// product add section------------------------------------------
@override
FutureResult<String> addPharmacyProductDetails({
  required List<Map<String, dynamic>> productListMapData,
}) async {
  final WriteBatch batch = _firebaseFirestore.batch();

  try {
    for (var productMapData in productListMapData) {
      final id = _firebaseFirestore
          .collection(FirebaseCollections.pharmacyProduct)
          .doc()
          .id;

      productMapData.update('id', (value) => id);

      // Add the product data to the batch
      final docRef = _firebaseFirestore
          .collection(FirebaseCollections.pharmacyProduct)
          .doc(id);
      batch.set(docRef, productMapData);
    }

    // Commit the batch
    await batch.commit();

    return right('Successfully uploaded the products');
  } on FirebaseException catch (e) {
    log(e.message!);
    return left(MainFailure.firebaseException(errMsg: e.message.toString()));
  } catch (e) {
    return left(MainFailure.generalException(errMsg: e.toString()));
  }
}
/* -------------------------------------------------------------------------- */
/* -------------- MEDICINE EQUIPMENT AND OTHE FORM AND PACKAGE -------------- */
@override
FutureResult<MedicineData> getproductFormAndPackageList() async {
  try {
    List<String>? medicineForm;
    List<String>? medicinePackage;
    List<String>? equipmentType;
    List<String>? othersCategoryType;
    List<String>? othersPackage;
    List<String>? othersForm;

    await _firebaseFirestore
        .collection(FirebaseCollections.productsForm)
        .doc('medicine')
        .get()
        .then((value) {
      var data = value.data() as Map<String, dynamic>;
      List<dynamic> medicineFormList = data['medicineFormList'] ?? [];
      List<dynamic> medicinePackageList = data['medicinePackageList'] ?? [];
      List<dynamic> equipmentTypeList = data['equipmentTypeList'] ?? [];
      List<dynamic> otherCategoryTypeList = data['otherCategoryTypeList'] ?? [];
      List<dynamic> otherProductFormList = data['otherProductFormList'] ?? [];
      List<dynamic> otherProductPackageList = data['otherProductPackageList'] ?? [];

      // Convert all to lowercase and trim
      medicineForm = medicineFormList.map((item) {
        return (item['medicineForm'] as String).trim().toLowerCase();
      }).toList();
      medicinePackage = medicinePackageList.map((item) {
        return (item['medicinePackage'] as String).trim().toLowerCase();
      }).toList();
      othersCategoryType = otherCategoryTypeList.map((item) {
        return (item['otherCategoryType'] as String).trim().toLowerCase();
      }).toList();
      equipmentType = equipmentTypeList.map((item) {
        return (item['equipmentType'] as String).trim().toLowerCase();
      }).toList();
      othersForm = otherProductFormList.map((item) {
        return (item['otherProductForm'] as String).trim().toLowerCase();
      }).toList();
      othersPackage = otherProductPackageList.map((item) {
        return (item['otherProductPackage'] as String).trim().toLowerCase();
      }).toList();
    });

    return right(MedicineData(
      equipmentType: equipmentType ?? [],
      othersCategoryType: othersCategoryType ?? [],
      othersPackage: othersPackage ?? [],
      othersForm: othersForm ?? [],
      medicineForm: medicineForm ?? [],
      medicinePackage: medicinePackage ?? [],
    ));
  } on FirebaseException catch (e) {
    return left(MainFailure.firebaseException(errMsg: e.toString()));
  } catch (e) {
    return left(MainFailure.generalException(errMsg: e.toString()));
  }
}


/* -------------------------------------------------------------------------- */

  
}
