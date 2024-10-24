import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:healthycart_pharmacy/core/failures/main_failure.dart';
import 'package:healthycart_pharmacy/core/general/firebase_collection.dart';
import 'package:healthycart_pharmacy/core/general/typdef.dart';
import 'package:healthycart_pharmacy/core/services/image_picker.dart';
import 'package:healthycart_pharmacy/core/services/pdf_picker.dart';
import 'package:healthycart_pharmacy/features/add_pharmacy_form_page/domain/i_form_facade.dart';
import 'package:healthycart_pharmacy/features/add_pharmacy_form_page/domain/model/pharmacy_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IFormFeildFacade)
class IFormFieldImpl implements IFormFeildFacade {
  IFormFieldImpl(this._firebaseFirestore, this._imageService, this._pdfService);
  final FirebaseFirestore _firebaseFirestore;
  final ImageService _imageService;
  final PdfPickerService _pdfService;
  @override
  /////////////adding hospital to the collection
  FutureResult<String> addPharmacyDetails({
    required PharmacyModel pharmacyDetails,
    required String pharmacyId,
  }) async {
    try {
      final batch = _firebaseFirestore.batch();
      batch.update(
          _firebaseFirestore
              .collection(FirebaseCollections.pharmacy)
              .doc(pharmacyId),
          pharmacyDetails.toFormMap());
      batch.update(
          _firebaseFirestore
              .collection(FirebaseCollections.counts)
              .doc('htfK5JIPTaZVlZi6fGdZ'),
          {'pendingPharmacy': FieldValue.increment(1)});
      await batch.commit();
      return right('Sucessfully sent for review');
    } on FirebaseException catch (e) {
      return left(MainFailure.firebaseException(errMsg: e.code));
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

//Image section -------------------------------------
  @override
  FutureResult<File> getImage() async {
    return await _imageService.getGalleryImage();
  }

  @override
  Future<Either<MainFailure, String>> saveImage(
      {required File imageFile}) async {
    return await _imageService.saveImage(
        imageFile: imageFile, folderName: 'Pharmacy');
  }

  @override
  FutureResult<Unit> deleteImage(
      {required String imageUrl, required String pharmacyId}) async {
    try {
      await _imageService.deleteImageUrl(imageUrl: imageUrl).then((value) {
        value.fold((failure) {
          return left(failure);
        }, (sucess) async {
          await _firebaseFirestore
              .collection(FirebaseCollections.pharmacy)
              .doc(pharmacyId)
              .update({'pharmacyImage': null}).then((value) {});
        });
      });
      return right(unit);
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }
///////////////////////////////////////////////////////////////////////////

  @override
  FutureResult<File> getPDF() async {
    return await _pdfService.getPdfFile();
  }

  @override
  FutureResult<String?> savePDF({
    required File pdfFile,
  }) async {
    return await _pdfService.uploadPdf(pdfFile: pdfFile);
  }

  @override
  FutureResult<String?> deletePDF({
    required String pharmacyId,
    required String pdfUrl,
  }) async {
    try {
      await _pdfService.deletePdfUrl(url: pdfUrl).then((value) {
        value.fold((failure) {
          return left(failure);
        }, (sucess) async {
          await _firebaseFirestore
              .collection(FirebaseCollections.pharmacy)
              .doc(pharmacyId)
              .update({'pharmacyDocumentLicense': null}).then((value) {});
        });
      });
      return right('Sucessfully removed');
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

  ///update section from profile--------------------
  @override
  FutureResult<String> updatePharmacyForm({
    required PharmacyModel pharmacyDetails,
    required String pharmacyId,
  }) async {
    try {
      await _firebaseFirestore
          .collection(FirebaseCollections.pharmacy)
          .doc(pharmacyId)
          .update(pharmacyDetails.toEditMap());
      return right('Sucessfully sent for review');
    } on FirebaseException catch (e) {
      return left(MainFailure.firebaseException(errMsg: e.code));
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

}
