import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthycart_pharmacy/core/failures/main_failure.dart';
import 'package:healthycart_pharmacy/core/general/firebase_collection.dart';
import 'package:healthycart_pharmacy/features/add_pharmacy_form_page/domain/model/pharmacy_model.dart';
import 'package:healthycart_pharmacy/features/authenthication/domain/i_auth_facade.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IAuthFacade)
class IAuthImpl implements IAuthFacade {
  IAuthImpl(this._firebaseAuth, this._firestore);
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  String? verificationId; // phone verification Id
  int? forceResendingToken;
  late StreamSubscription _streamSubscription;

  @override
  Stream<Either<MainFailure, bool>> verifyPhoneNumber(
      String phoneNumber) async* {
    final StreamController<Either<MainFailure, bool>> controller =
        StreamController<Either<MainFailure, bool>>();

    _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          controller.add(left(const MainFailure.invalidPhoneNumber(
              errMsg: 'Phone number is not valid')));
        } else {
          controller.add(left(MainFailure.invalidPhoneNumber(errMsg: e.code)));
        }
      },
      codeSent: (String verificationId, int? forceResendingToken) {
        //verification id is stored in the state
        this.verificationId = verificationId;
        this.forceResendingToken = forceResendingToken;
        controller.add(right(true));
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );

    yield* controller.stream;
  }

  @override
  Future<Either<MainFailure, String>> verifySmsCode({
    required String smsCode,
  }) async {
    
    try {
      final PhoneAuthCredential phoneAuthCredential =
          PhoneAuthProvider.credential(
              verificationId: verificationId ?? "", smsCode: smsCode);

      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);
      await saveUser(
        phoneNo: userCredential.user!.phoneNumber!,
        pharmacyId: userCredential.user!.uid,
      );

      return right(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      return left(MainFailure.invalidPhoneNumber(errMsg: e.code));
    }
  }

  Future<void> saveUser({
    required String pharmacyId,
    required String phoneNo,
  }) async {
    final user = await _firestore
        .collection(FirebaseCollections.pharmacy)
        .doc(pharmacyId)
        .get();
    if (user.data() != null) {
      return;
    } else {
      await _firestore
          .collection(FirebaseCollections.pharmacy)
          .doc(pharmacyId)
          .set(PharmacyModel()
              .copyWith(id: pharmacyId, phoneNo: phoneNo)
              .toMap());
    }
  }

  @override
  Stream<Either<MainFailure, PharmacyModel>> pharmacyStreamFetchedData(
      String pharmacyId) async* {
    final StreamController<Either<MainFailure, PharmacyModel>>
        hospitalStreamController =
        StreamController<Either<MainFailure, PharmacyModel>>();
    try {
      _streamSubscription = _firestore
          .collection(FirebaseCollections.pharmacy)
          .doc(pharmacyId)
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          hospitalStreamController.add(
              right(PharmacyModel.fromMap(doc.data() as Map<String, dynamic>)));
        }
      });
    } on FirebaseException catch (e) {
      hospitalStreamController
          .add(left(MainFailure.firebaseException(errMsg: e.code)));
    } catch (e) {
      hospitalStreamController
          .add(left(MainFailure.generalException(errMsg: e.toString())));
    }
    yield* hospitalStreamController.stream;
  }

  @override
  Future<void> cancelStream() async {
    await _streamSubscription.cancel();
  }

  @override
  Future<Either<MainFailure, String>> pharmacyLogOut() async {
    try {
      cancelStream();
      await _firebaseAuth.signOut();
      return right('Sucessfully Logged Out');
    } catch (e) {
      return left(const MainFailure.generalException(
          errMsg: "Couldn't able to log out"));
    }
  }
}
