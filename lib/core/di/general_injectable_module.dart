import 'package:firebase_storage/firebase_storage.dart';
import 'package:healthycart_pharmacy/core/di/injection.dart';
import 'package:healthycart_pharmacy/core/services/excel_file_servce.dart';
import 'package:healthycart_pharmacy/core/services/get_network_time.dart';
import 'package:healthycart_pharmacy/core/services/image_picker.dart';
import 'package:healthycart_pharmacy/core/services/location_service.dart';
import 'package:healthycart_pharmacy/core/services/pdf_picker.dart';
import 'package:healthycart_pharmacy/core/services/url_launcher.dart';
import 'package:injectable/injectable.dart';

@module
abstract class GeneralInjecatbleModule {
  @lazySingleton
  ImageService get imageServices => ImageService(sl<FirebaseStorage>());
  @lazySingleton
  LocationService get locationServices => LocationService();
  @lazySingleton
  PdfPickerService get pdfPickerService => PdfPickerService(sl<FirebaseStorage>());
  @lazySingleton
  UrlService get urlService => UrlService();
  @lazySingleton
  NetworkTimeService get networkTimeService => NetworkTimeService();
  @lazySingleton
  CSVFileService get csvFileService => CSVFileService(sl<FirebaseStorage>());
}
