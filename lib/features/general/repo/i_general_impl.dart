import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthycart_pharmacy/core/general/firebase_collection.dart';
import 'package:healthycart_pharmacy/features/general/data/i_general_facade.dart';
import 'package:healthycart_pharmacy/features/general/data/model/general_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IGeneralFacade)
class IGeneralImpl implements IGeneralFacade {
  IGeneralImpl(this.firestore);
  final FirebaseFirestore firestore;

  @override
  Stream<GeneralModel?> fetchData() async* {
    final snapshot = firestore
        .collection(FirebaseCollections.general)
        .doc('general')
        .snapshots();
    final user = snapshot.map(
      (event) {
        if (event.exists) {
          return GeneralModel.fromMap(event.data() as Map<String, dynamic>);
        } else {
          return null;
        }
      },
    );
    yield* user;
  }
}
