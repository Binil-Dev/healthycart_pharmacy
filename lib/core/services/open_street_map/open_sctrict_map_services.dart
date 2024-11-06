import 'dart:convert';
import 'dart:developer';

// ignore: depend_on_referenced_packages
import 'package:geocoding/geocoding.dart';
import 'package:healthycart_pharmacy/core/custom/toast/toast.dart';
import 'package:healthycart_pharmacy/core/services/open_street_map/open_street_map_model.dart';
import 'package:healthycart_pharmacy/features/location_picker/domain/model/location_model.dart';
import 'package:http/http.dart' as http;

class OpenStritMapServices {
  //USER CURRENT LOCATION
  static Future<PlaceMark> fetchCurrentLocaion({
    required String latitude,
    required String longitude,
  }) async {
     final headers = {'User-Agent': 'HealthyCart Pharmacy'};
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude',
    );
    final response = await http.get(url,headers:headers);
    if (response.statusCode == 200) {
      final openStreetMap = OpentreetMapModel.fromMap(
        json.decode(response.body) as Map<String, dynamic>,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
          double.tryParse(latitude)!, double.tryParse(longitude)!);
      final placemark = placemarks[0];

      log(placemark.toJson().toString());

      final localArea = (placemark.locality ?? '').isNotEmpty
          ? placemark.locality
          : openStreetMap.localArea;
      final subAdministrativeArea = (placemark.subAdministrativeArea ?? '').isNotEmpty
          ? placemark.subAdministrativeArea
          : openStreetMap.district;
      return PlaceMark(
        country: openStreetMap.country ?? '',
        district: subAdministrativeArea!,
        geoPoint: LandMark(
          latitude: openStreetMap.latitude!,
          longitude: openStreetMap.longitude!,
        ),
        localArea: localArea,
        pincode: openStreetMap.pincode ?? '',
        state: openStreetMap.state ?? '',
      );
    } else {
      log('ERROR IN CONVERT TO ADRESS FUNCTION : ${response.statusCode}');
      CustomToast.errorToast(text: 'Please try again');
      throw Exception('Failed to load album');
    }
  }

  //SEARCH LOCATION
  static Future<List<PlaceMark>> searchPlaces({
    required String input,
  }) async {
     final headers = {'User-Agent': 'HealthyCart Pharmacy'};
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search.php?q=$input&format=json&addressdetails=1&limit=20&countrycodes=in',
    );
    final response = await http.get(url,headers:headers);
    if (response.statusCode == 200) {
      final placeMarks = <PlaceMark>[];
      final data = json.decode(response.body) as List<dynamic>;
      for (final item in data) {
        final openStreetMap = OpentreetMapModel.fromMap(
          item as Map<String, dynamic>,
        );
        placeMarks.add(
          PlaceMark(
            country: openStreetMap.country ?? '',
            district: openStreetMap.district ?? '',
            geoPoint: LandMark(
              latitude: openStreetMap.latitude!,
              longitude: openStreetMap.longitude!,
            ),
            localArea: openStreetMap.localArea ?? '',
            pincode: openStreetMap.pincode ?? '',
            state: openStreetMap.state ?? '',
          ),
        );
      }
      return placeMarks;
    } else {
      log('ERROR IN CONVERT TO ADRESS FUNCTION : ${response.statusCode}');
      CustomToast.errorToast(
          text: 'ERROR IN CONVERT TO ADRESS FUNCTION : ${response.statusCode}');

      throw Exception('Failed to load album');
    }
  }
}
