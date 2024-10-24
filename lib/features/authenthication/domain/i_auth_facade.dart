import 'package:dartz/dartz.dart';
import 'package:healthycart_pharmacy/core/failures/main_failure.dart';
import 'package:healthycart_pharmacy/features/add_pharmacy_form_page/domain/model/pharmacy_model.dart';

abstract class IAuthFacade {
  //factory IAuthFacade() => IAuthImpl(FirebaseAuth.instance);
  Stream<Either<MainFailure, bool>> verifyPhoneNumber(String phoneNumber);
  Future<Either<MainFailure, String>> verifySmsCode({
    required String smsCode,
  });

  Stream<PharmacyModel?>
      pharmacyStreamFetchedData() async* {
    throw UnimplementedError('fetchPharmacy() not implemented');
  }

  Future<Either<MainFailure, String>> pharmacyLogOut();
  Future<void> cancelStream();
}
