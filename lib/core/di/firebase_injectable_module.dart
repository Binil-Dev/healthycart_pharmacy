import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:healthycart_pharmacy/firebase_options.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_storage/firebase_storage.dart';



@module
abstract class FirebaseInjecatbleModule {
  // ignore: invalid_annotation_target
  @preResolve
  Future<FirebaseService> get firebaseService => FirebaseService.init();

  @lazySingleton
  FirebaseAuth get auth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseStorage get storage => FirebaseStorage.instance;

  @lazySingleton
  FirebaseFirestore get repo => FirebaseFirestore.instance;
}

class FirebaseService {
  static Future<FirebaseService> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    return FirebaseService();
  }
}
