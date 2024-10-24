import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:healthycart_pharmacy/core/failures/main_failure.dart';
import 'package:healthycart_pharmacy/core/general/firebase_collection.dart';
import 'package:healthycart_pharmacy/core/general/typdef.dart';
import 'package:healthycart_pharmacy/core/services/get_network_time.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/domain/i_order_facade.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/domain/model/day_transaction_model.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/domain/model/pharmacy_order_model.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/domain/model/pharmacy_transaction.dart';

import 'package:injectable/injectable.dart';

@LazySingleton(as: IOrderFacade)
class IOrderImpl implements IOrderFacade {
  IOrderImpl(this._firebaseFirestore, this._networkTimeService);
  final FirebaseFirestore _firebaseFirestore;
  final NetworkTimeService _networkTimeService;
  late StreamSubscription _streamSubscription;
  @override
  Stream<Either<MainFailure, List<PharmacyOrderModel>>> pharmacyNewOrderData(
      {required String pharmacyId, required String? searchPhoneNumber}) async* {
    final StreamController<Either<MainFailure, List<PharmacyOrderModel>>>
        newOrderStreamController =
        StreamController<Either<MainFailure, List<PharmacyOrderModel>>>();
    try {
        Query query = _firebaseFirestore
          .collection(FirebaseCollections.pharmacyOrder)
          .orderBy('createdAt', descending: true)
          .where(Filter.and(
            Filter('pharmacyId', isEqualTo: pharmacyId),
            Filter('orderStatus', isEqualTo: 0),
          ));
      if (searchPhoneNumber != null && searchPhoneNumber.isNotEmpty) {
        query = query.where('userDetails.phoneNo', isEqualTo: searchPhoneNumber);
      }
      _streamSubscription = query
          .snapshots()
          .listen(
        (docsList) {
          final newOrderList = docsList.docs
              .map((e) =>
                  PharmacyOrderModel.fromMap(e.data() as Map<String, dynamic>).copyWith(id: e.id))
              .toList();
          log('Data fetched::');
          newOrderStreamController.add(right(newOrderList));
        },
      );
    } on FirebaseException catch (e) {
      newOrderStreamController
          .add(left(MainFailure.firebaseException(errMsg: e.code)));
    } catch (e) {
      newOrderStreamController
          .add(left(MainFailure.generalException(errMsg: e.toString())));
    }
    yield* newOrderStreamController.stream;
  }

  @override
  Future<void> cancelStream() async {
    await _streamSubscription.cancel();
  }

  /* ---------------------------- ON PROCESS ORDER ---------------------------- */
  @override
  Stream<Either<MainFailure, List<PharmacyOrderModel>>> pharmacyOnProcessData(
      {required String pharmacyId, required String? searchPhoneNumber}) async* {
    final StreamController<Either<MainFailure, List<PharmacyOrderModel>>>
        onProcessController =
        StreamController<Either<MainFailure, List<PharmacyOrderModel>>>();
    try {
      Query query = _firebaseFirestore
          .collection(FirebaseCollections.pharmacyOrder)
          .orderBy('acceptedAt', descending: true)
          .where(Filter.and(
            Filter('pharmacyId', isEqualTo: pharmacyId),
            Filter('orderStatus', isEqualTo: 1),
          ));
      if (searchPhoneNumber != null && searchPhoneNumber.isNotEmpty) {
        query = query.where('userDetails.phoneNo', isEqualTo: searchPhoneNumber);
      }
      _streamSubscription = query
          .snapshots()
          .listen(
        (docsList) {
          final newOrderList = docsList.docs
              .map((e) =>
                  PharmacyOrderModel.fromMap(e.data()as Map<String, dynamic>).copyWith(id: e.id ))
              .toList();
          onProcessController.add(right(newOrderList));
        },
      );
    } on FirebaseException catch (e) {
      onProcessController
          .add(left(MainFailure.firebaseException(errMsg: e.code)));
    } catch (e) {
      onProcessController
          .add(left(MainFailure.generalException(errMsg: e.toString())));
    }
    yield* onProcessController.stream;
  }

  /* ------------------------- UPDATE IN PENDING ORDER ------------------------ */
  @override
  FutureResult<PharmacyOrderModel> updateProductOrderPendingDetails(
      {required String orderId,
      required PharmacyOrderModel orderProducts}) async {
    log(orderId);
    try {
      await _firebaseFirestore
          .collection(FirebaseCollections.pharmacyOrder)
          .doc(orderId)
          .update(orderProducts.toEditMap());

      return right(orderProducts.copyWith(id: orderId));
    } on FirebaseException catch (e) {
      return left(MainFailure.firebaseException(errMsg: e.message.toString()));
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

  /* ------------------------- UPDATE IN PENDING ORDER ------------------------ */
  @override
  FutureResult<PharmacyOrderModel> updateProductOrderOnProcessDetails({
    required String orderId,
    required String pharmacyId,
    required PharmacyOrderModel orderProducts,
    DayTransactionModel? dayTransactionModel,
    String? dayTransactionDate,
  }) async {
    try {
      /* ------------------------------ ACCEPT ORDER AND PACKING AND DELIVERY ------------------------------ */
      if (orderProducts.orderStatus != 2) {
        await _firebaseFirestore
            .collection(FirebaseCollections.pharmacyOrder)
            .doc(orderId)
            .update(orderProducts.toMap());
      } else {
        /* ----------------------------- COMPLETE ORDER ----------------------------- */
        final batch = _firebaseFirestore.batch();
        final formattedDate =
            await _networkTimeService.getFormattedNetworkTime();

        final orderDoc = _firebaseFirestore
            .collection(FirebaseCollections.pharmacyOrder)
            .doc(orderId);
        final transactionDoc = _firebaseFirestore
            .collection(FirebaseCollections.transactionCollection)
            .doc(pharmacyId);
        final dayTransactionDoc = _firebaseFirestore
            .collection(FirebaseCollections.pharmacy)
            .doc(pharmacyId)
            .collection(FirebaseCollections.dayTransaction)
            .doc(formattedDate);
        final pharmacyDoc = _firebaseFirestore
            .collection(FirebaseCollections.pharmacy)
            .doc(pharmacyId);

        batch.update(orderDoc, orderProducts.toMap());
        batch.update(transactionDoc, {
          'totalTransactionAmt':
              FieldValue.increment(orderProducts.finalAmount!),
          'totalCommissionPending':
              FieldValue.increment(orderProducts.commissionAmt!)
        });

        if (orderProducts.paymentType == 'Online') {
          batch.update(transactionDoc, {
            'onlinePayment':
                FieldValue.increment(orderProducts.finalAmount ?? 0)
          });
        } else {
          batch.update(transactionDoc, {
            'offlinePayment':
                FieldValue.increment(orderProducts.finalAmount ?? 0)
          });
        }
        batch.update(pharmacyDoc, {'dayTransaction': formattedDate});

        if (dayTransactionDate == formattedDate) {
          batch.update(dayTransactionDoc, {
            'totalAmount': FieldValue.increment(orderProducts.finalAmount ?? 0),
            'commission':
                FieldValue.increment(orderProducts.commissionAmt ?? 0),
            'offlinePayment': orderProducts.paymentType != 'Online'
                ? FieldValue.increment(orderProducts.finalAmount ?? 0)
                : FieldValue.increment(0),
            'onlinePayment': orderProducts.paymentType == 'Online'
                ? FieldValue.increment(orderProducts.finalAmount ?? 0)
                : FieldValue.increment(0),
          });
        } else {
          final networkTime = await _networkTimeService.getNetworkTime();
          dayTransactionModel?.createdAt = Timestamp.fromDate(networkTime);
          batch.set(dayTransactionDoc, dayTransactionModel?.toMap());
        }
        await batch.commit();
      }

      return right(orderProducts.copyWith(id: orderId));
    } on FirebaseException catch (e) {
      return left(MainFailure.firebaseException(errMsg: e.message.toString()));
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

  /* ---------------------------- GET COMPLETED ORDER---------------------------- */
  DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  bool noMoreData = false;
  @override
  FutureResult<List<PharmacyOrderModel>> getCompletedOrderDetails(
      {required String pharmacyId,
      required int initiallimit,
      required String? searchPhoneNumber}) async {
    try {
      if (noMoreData) return right([]);
         int limit = lastDoc == null ? initiallimit : 4;
      Query query = _firebaseFirestore
          .collection(FirebaseCollections.pharmacyOrder)
          .orderBy('completedAt', descending: true)
          .where(Filter.and(
            Filter('pharmacyId', isEqualTo: pharmacyId),
            Filter('orderStatus', isEqualTo: 2),
          ));
      if (searchPhoneNumber != null && searchPhoneNumber.isNotEmpty) {
        query =
            query.where('userDetails.phoneNo', isEqualTo: searchPhoneNumber);
      }
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc!);
        log(lastDoc!.id.toString());
      }
      final snapshots = await query.limit(limit).get();
      if (snapshots.docs.length < limit || snapshots.docs.isEmpty) {
        noMoreData = true;
      } else {
        lastDoc = snapshots.docs.last as DocumentSnapshot<Map<String, dynamic>>;
      }
      final List<PharmacyOrderModel> productList = snapshots.docs
          .map((e) =>
              PharmacyOrderModel.fromMap(e.data() as Map<String, dynamic>)
                  .copyWith(id: e.id))
          .toList();
      return right(productList);
    } on FirebaseException catch (e) {
      return left(MainFailure.firebaseException(errMsg: e.message.toString()));
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

  @override
  void clearFetchData() {
    noMoreData = false;
    lastDoc = null;
  }

/* ------------------------- CANCELLED ORDER SECTION ------------------------ */
  @override
  FutureResult<List<PharmacyOrderModel>> getCancelledOrderDetails(
      {required String pharmacyId, required String? searchPhoneNumber}) async {
    try {
      final limit = lastDoc == null ? 6 : 3;
      if (noMoreData) return right([]);
      Query query = _firebaseFirestore
          .collection(FirebaseCollections.pharmacyOrder)
          .orderBy('rejectedAt', descending: true)
          .where(Filter.and(
            Filter('pharmacyId', isEqualTo: pharmacyId),
            Filter('orderStatus', isEqualTo: 3),
          ));
      if (searchPhoneNumber != null && searchPhoneNumber.isNotEmpty) {
        query =
            query.where('userDetails.phoneNo', isEqualTo: searchPhoneNumber);
      }
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc!);
        log(lastDoc!.id.toString());
      }
      final snapshots = await query.limit(limit).get();
      if (snapshots.docs.length < limit || snapshots.docs.isEmpty) {
        noMoreData = true;
      } else {
        lastDoc = snapshots.docs.last as DocumentSnapshot<Map<String, dynamic>>;
      }
      final List<PharmacyOrderModel> productList = snapshots.docs
          .map((e) =>
              PharmacyOrderModel.fromMap(e.data() as Map<String, dynamic>)
                  .copyWith(id: e.id))
          .toList();
      return right(productList);
    } on FirebaseException catch (e) {
      return left(MainFailure.firebaseException(errMsg: e.message.toString()));
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }

  /* ------------------------- GET TRANSACTION DETAIL ------------------------- */
  @override
  FutureResult<PharmacyTransactionModel> getTransactionData(
      {required String pharmacyId}) async {
    try {
      final doc = await _firebaseFirestore
          .collection(FirebaseCollections.transactionCollection)
          .where('id', isEqualTo: pharmacyId)
          .get();

      return right(PharmacyTransactionModel.fromMap(doc.docs.single.data()));
    } catch (e) {
      return left(MainFailure.generalException(errMsg: e.toString()));
    }
  }
}
