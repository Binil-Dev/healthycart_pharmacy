import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:healthycart_pharmacy/core/failures/main_failure.dart';
import 'package:healthycart_pharmacy/core/general/typdef.dart';


class CSVFileService {
  CSVFileService(this._storage);
  final FirebaseStorage _storage;


  /// getting Excel using  file picker ------------
  // FutureResult<File> getExcelFile() async {
  //   final FilePickerResult? pickedFile;

  //   try {
  //     pickedFile = await FilePicker.platform.pickFiles(
  //       type: FileType.custom,
  //        allowedExtensions: ['xls', 'xlsx'],
  //     );
  //     if (pickedFile != null && pickedFile.files.isNotEmpty) {
  //       PlatformFile file = pickedFile.files.first;
  //       File excelFile = File(file.path!);
  //       return right(excelFile);
  //     } else {
  //       return left(const MainFailure.generalException(
  //           errMsg: "Couldn't able to pick excel file"));
  //     }
  //   } catch (e) {
  //     return left(const MainFailure.generalException(
  //         errMsg: "Couldn't able to pick excel file"));
  //   }
  // }
  // Existing method for picking Excel file

Future<Either<MainFailure, File>> getCSVFile() async {
  final FilePickerResult? pickedFile;

  try {
    pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (pickedFile != null && pickedFile.files.isNotEmpty) {
      PlatformFile file = pickedFile.files.first;
      File csvFile = File(file.path!);
      return right(csvFile);
    } else {
      return left(const MainFailure.generalException(
          errMsg: "Couldn't able to pick CSV file"));
    }
  } catch (e) {
    return left(const MainFailure.generalException(
        errMsg: "Couldn't able to pick csv file"));
  }
}


/// updloading CSV to  firebase firestore ------------
  FutureResult<String?> uploadCSV({
    required File csvFile,
  }) async {
    final String csvName =
        'pharmacy_CSV/${DateTime.now().microsecondsSinceEpoch}.CSV';
    final String? downloadCSVUrl;
    try {
      await _storage
          .ref(csvName)
          .putFile(csvFile, SettableMetadata(contentType: 'file/CSV'));
      downloadCSVUrl = await _storage.ref(csvName).getDownloadURL();
      return right(downloadCSVUrl);
    } catch (e) {
      return left(const MainFailure.generalException(
          errMsg: "Couldn't able to save CSV file"));
    }
  }
/// delete CSV ------------
  FutureResult<String?> deleteCSVUrl({
    required String? url,
  }) async {
    if (url == null) {
      return left(const MainFailure.generalException(
          errMsg: "Can't able to remove the CSV."));
    }
    final cSVRef = _storage.refFromURL(url);
    try {
      await cSVRef.delete();
      return right('CSV removed sucessfully');
    } catch (e) {
      return left(const MainFailure.generalException(
          errMsg: "Couldn't able to remove the CSV."));
    }
  }
}
