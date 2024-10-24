// ignore_for_file: public_member_api_docs, sort_constructors_first

// ignore_for_file: non_constant_identifier_names

class GeneralModel {
  String minAppstoreVersionPharmacy;
  String minPlaystoreVersionPharmacy;
  GeneralModel({
    required this.minAppstoreVersionPharmacy,
    required this.minPlaystoreVersionPharmacy,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'minAppstoreVersionPharmacy': minAppstoreVersionPharmacy,
      'minPlaystoreVersionPharmacy': minPlaystoreVersionPharmacy,
    };
  }

  factory GeneralModel.fromMap(Map<String, dynamic> map) {
    return GeneralModel(
      minAppstoreVersionPharmacy: map['minAppstoreVersionPharmacy'] as String? ??'',
      minPlaystoreVersionPharmacy: map['minPlaystoreVersionPharmacy'] as String? ??'',
    );
  }
}
