import 'package:dartz/dartz.dart';
import 'package:healthycart_pharmacy/core/failures/main_failure.dart';
import 'package:healthycart_pharmacy/core/general/typdef.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/domain/model/day_transaction_model.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/domain/model/pharmacy_order_model.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/domain/model/pharmacy_transaction.dart';

abstract class IOrderFacade {
  Stream<Either<MainFailure, List<PharmacyOrderModel>>> pharmacyNewOrderData({
    required String pharmacyId,required String? searchPhoneNumber
  });
  Stream<Either<MainFailure, List<PharmacyOrderModel>>> pharmacyOnProcessData({
    required String pharmacyId,required String? searchPhoneNumber
  });
  Future<void> cancelStream();
  FutureResult<PharmacyOrderModel> updateProductOrderPendingDetails(
      {required String orderId, required PharmacyOrderModel orderProducts,});
  FutureResult<PharmacyOrderModel> updateProductOrderOnProcessDetails(
      {required String orderId, required PharmacyOrderModel orderProducts,required String pharmacyId,DayTransactionModel? dayTransactionModel,String? dayTransactionDate,});
  FutureResult<List<PharmacyOrderModel>> getCompletedOrderDetails({
    required String pharmacyId, required int initiallimit,required String? searchPhoneNumber
  });
  FutureResult<List<PharmacyOrderModel>> getCancelledOrderDetails({
    required String pharmacyId,required String? searchPhoneNumber
  });
  void clearFetchData();

    FutureResult<PharmacyTransactionModel> getTransactionData(
      {required String pharmacyId});
}


