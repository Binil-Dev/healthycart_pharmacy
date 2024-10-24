import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:healthycart_pharmacy/core/custom/toast/toast.dart';
import 'package:healthycart_pharmacy/core/services/easy_navigation.dart';
import 'package:healthycart_pharmacy/core/services/fcm_notification.dart';
import 'package:healthycart_pharmacy/features/authenthication/application/authenication_provider.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/domain/i_order_facade.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/domain/model/day_transaction_model.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/domain/model/pharmacy_order_model.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/domain/model/pharmacy_transaction.dart';
import 'package:healthycart_pharmacy/features/pharmacy_orders/domain/model/product_quantity_model.dart';
import 'package:healthycart_pharmacy/features/pharmacy_products/domain/model/pharmacy_product_model.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

@injectable
class RequestPharmacyProvider extends ChangeNotifier {
  RequestPharmacyProvider(this._iOrderFacade);
  final IOrderFacade _iOrderFacade;
  bool fetchloading = false;
  int tabIndex = 0;

  void changeTabINdex({
    required int index,
  }) {
    tabIndex = index;
    notifyListeners();
  }

  List<String> tabItems = [
    'New Order',
    'On Process',
    'Completed',
    'Cancelled',
  ];

  /* ----------------------------- PRODUCT SECTION ---------------------------- */

  List<ProductAndQuantityModel> pharmacyUserProducts = [];
  List<PharmacyOrderModel> newOrderList = [];
  List<PharmacyOrderModel> onProcessOrderList = [];
  List<PharmacyOrderModel> completedOrderList = [];
  List<PharmacyOrderModel> cancelledOrderList = [];
  num totalAmount = 0;
  num totalFinalAmount = 0;

  void addAllProductDetails(
      {required List<ProductAndQuantityModel> productDataList}) {
    if (pharmacyUserProducts.isNotEmpty) return;
    pharmacyUserProducts.addAll(productDataList);
  }

/* ---------------------------- PRICE CALCULATOR ---------------------------- */
  num discountAmountAsDifference = 0;
  void totalAmountCalclator() {
    totalAmount = 0;
    totalFinalAmount = 0;
    num totalDiscountAmount = 0;
    num totalMRPAmount = 0;

    for (int i = 0; i < pharmacyUserProducts.length; i++) {
      if (pharmacyUserProducts[i].productData?.productDiscountRate == null) {
        totalDiscountAmount = (pharmacyUserProducts[i].quantity! *
            pharmacyUserProducts[i].productData!.productMRPRate!);
      } else {
        totalDiscountAmount = (pharmacyUserProducts[i].quantity! *
            pharmacyUserProducts[i].productData!.productDiscountRate!);
      }
      totalMRPAmount = (pharmacyUserProducts[i].quantity! *
          pharmacyUserProducts[i].productData!.productMRPRate!);

      totalAmount += totalMRPAmount;
      totalFinalAmount += totalDiscountAmount;
    }
    discountAmountAsDifference = totalAmount - totalFinalAmount;
    notifyListeners();
  }

/* -------------------------------------------------------------------------- */

/* ----------------------------- DATE CONVERTOR ----------------------------- */
  String dateFromTimeStamp(Timestamp createdAt) {
    final date =
        DateTime.fromMillisecondsSinceEpoch(createdAt.millisecondsSinceEpoch);
    return DateFormat('dd/MM/yyyy').format(date);
  }

/* -------------------------------------------------------------------------- */
/* ------------------------------ DELIVERY  AND PAYMENT TYPE ----------------------------- */
  String deliveryType(String delivery) {
    if (delivery == "Home") {
      return 'Home Delivery';
    } else {
      return 'Pick-Up at pharmacy';
    }
  }

  String paymentType(String paymentType) {
    if (paymentType == "COD") {
      return 'Cash on delivery';
    } else if (paymentType == "Online") {
      return 'Online';
    } else {
      return 'Pending';
    }
  }

/* -------------------------------------------------------------------------- */
  /* ------------------------------ LAUNCH DIALER ----------------------------- */
  Future<void> lauchDialer({required String phoneNumber}) async {
    final Uri url = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      CustomToast.errorToast(text: 'Could not launch the dialer');
    }
  }

/* ------------------------ PRODUCT NEW ORDER STREAM SECTION ----------------------- */
  final TextEditingController searchNewRequestController =
      TextEditingController();
  void getPharmacyNewOrders({
    String? searchPhoneNumber,
  }) {
    String? pharmacyId = FirebaseAuth.instance.currentUser?.uid;
    fetchloading = true;
    notifyListeners();
    _iOrderFacade
        .pharmacyNewOrderData(
            pharmacyId: pharmacyId ?? '',
            searchPhoneNumber: searchNewRequestController.text)
        .listen((event) {
      event.fold(
        (err) {
          CustomToast.errorToast(text: err.errMsg);
          log(err.errMsg);
          fetchloading = false;
          notifyListeners();
        },
        (newOrders) {
          newOrderList = newOrders;
          fetchloading = false;
          notifyListeners();
        },
      );
    });

    notifyListeners();
  }

  Future<void> cancelStream() async {
    await _iOrderFacade.cancelStream();
  }
/* -------------------------------------------------------------------------- */

/* ------------------------ PRODUCT ON PROCESS ORDER STREAM SECTION ----------------------- */
  final TextEditingController searchAcceptedBookingsController =
      TextEditingController();
  void getpharmacyOnProcessData({
    String? searchPhoneNumber,
  }) {
    String? pharmacyId = FirebaseAuth.instance.currentUser?.uid;
    fetchloading = true;
    notifyListeners();
    _iOrderFacade
        .pharmacyOnProcessData(
            pharmacyId: pharmacyId ?? '', searchPhoneNumber: searchPhoneNumber)
        .listen((event) {
      event.fold(
        (err) {
           log(err.errMsg);
          CustomToast.errorToast(text: err.errMsg);
          fetchloading = false;
          notifyListeners();
        },
        (newOrders) {
          onProcessOrderList = newOrders;
          fetchloading = false;
          notifyListeners();
        },
      );
    });

    notifyListeners();
  }

  /* -------------------------------------------------------------------------- */
/* -------------------------- UPDATE PENDING ORDER -------------------------- */
  final reasonController = TextEditingController();
  final rejectionReasonController = TextEditingController();
  final deliveryController = TextEditingController();
  num? deliveryCharge = 0;
  num? previousDeliveryCharge = 0;
  PharmacyOrderModel? orderProducts;

  void removeProduct({required int index}) {
    pharmacyUserProducts.removeAt(index);
    totalAmountCalclator();
    notifyListeners();
  }

  void setDeliveryCharge() {
    deliveryCharge = num.parse(deliveryController.text);
    if (deliveryCharge != null) {
      totalFinalAmount -= previousDeliveryCharge!;
      totalFinalAmount += deliveryCharge!;
    }
    previousDeliveryCharge = deliveryCharge;
    notifyListeners();
  }

  void clearFiledAndData() {
    deliveryCharge = 0;
    previousDeliveryCharge = 0;
    reasonController.clear();
    deliveryController.clear();
    rejectionReasonController.clear();
    pharmacyUserProducts.clear();
    productMap.clear(); // clearing in the case of prescription
    notifyListeners();
  }

  Future<void> updateNewOrderDetails(
      {required PharmacyOrderModel productData,
      required int cancelOrApprove,
      required BuildContext context}) async {
    detailsPageProductsDetails(
        productData: productData, cancelOrApprove: cancelOrApprove);
    final result = await _iOrderFacade.updateProductOrderPendingDetails(
      orderId: productData.id ?? '',
      orderProducts: orderProducts!,
    );
    result.fold(
      (failure) {
        CustomToast.errorToast(text: failure.errMsg);
        EasyNavigation.pop(context: context);
        notifyListeners();
      },
      (orderProduct) {
        if (cancelOrApprove == 1) {
          sendFcmMessage(
              token: orderProduct.userDetails?.fcmToken ?? '',
              body:
                  'Your Order is approved by ${orderProduct.pharmacyDetails?.pharmacyName ?? 'Pharmacy'}, Click to check details!!',
              title: 'Healthy Cart Order Approved!!');
        } else {
          sendFcmMessage(
              token: orderProduct.userDetails?.fcmToken ?? '',
              body:
                  'Your Order is rejected by ${orderProduct.pharmacyDetails?.pharmacyName ?? 'Pharmacy'}, Click to check details!!',
              title: 'Healthy Cart Order Rejected!!');
        }
        CustomToast.sucessToast(
            text: (cancelOrApprove == 1)
                ? "The order is sent to user"
                : "The order is cancelled sucessfully.");
        EasyNavigation.pop(context: context);
        EasyNavigation.pop(context: context);
        // EasyNavigation.pushAndRemoveUntil(context: context, page: const HomeScreen());
        clearFiledAndData();
        notifyListeners();
      },
    );
  }

  void detailsPageProductsDetails(
      {required PharmacyOrderModel productData, required int cancelOrApprove}) {
    orderProducts = PharmacyOrderModel(
      productDetails: (cancelOrApprove == 3)
          ? productData.productDetails
          : pharmacyUserProducts,
      orderStatus: cancelOrApprove,
      paymentStatus: 0,
      deliveryCharge: deliveryCharge,
      totalDiscountAmount: (cancelOrApprove == 3)
          ? productData.totalDiscountAmount
          : (deliveryCharge == 0 || deliveryCharge == null)
              ? totalFinalAmount
              : totalFinalAmount - deliveryCharge!,
      totalAmount:
          (cancelOrApprove == 3) ? productData.totalAmount : totalAmount,
      finalAmount:
          (cancelOrApprove == 3) ? productData.finalAmount : totalFinalAmount,
      rejectReason: reasonController.text.isEmpty
          ? rejectionReasonController.text
          : reasonController.text,
      acceptedAt: (cancelOrApprove == 1) ? Timestamp.now() : null,
      rejectedAt: (cancelOrApprove == 3) ? Timestamp.now() : null,
      isRejectedByUser: (cancelOrApprove == 3) ? false : null,
    );
  }

  /* -------------------------------------------------------------------------- */
  /* ------------------------ PRESCRIPTION ADD QUANTITY ----------------------- */
  int quantityCount = 1;
  ProductAndQuantityModel? productPrescriptionAdd;
  Map<String, ProductAndQuantityModel> productMap = {};
  int? selectedIndex = -1;

  void setPrescriptionProductMap(
      {required PharmacyProductAddModel productDetail}) {
    if (productMap.containsKey(productDetail.id)) {
      productPrescriptionAdd = ProductAndQuantityModel(
          productData: productDetail,
          productId: productDetail.id,
          quantity: quantityCount);
      productMap[productDetail.id!] =
          productPrescriptionAdd ?? ProductAndQuantityModel();
    } else {
      quantityCount = 1;
      productPrescriptionAdd = ProductAndQuantityModel(
          productData: productDetail,
          productId: productDetail.id,
          quantity: quantityCount);
      productMap[productDetail.id!] =
          productPrescriptionAdd ?? ProductAndQuantityModel();
    }
    notifyListeners();
  }

  void removePrescriptionProduct({required String id}) {
    productMap.removeWhere(
      (key, value) => key == id,
    );
    notifyListeners();
  }

  // increment of the quantity from product details page
  void increment({required PharmacyProductAddModel productDetail}) {
    quantityCount++;
    setPrescriptionProductMap(productDetail: productDetail);
    notifyListeners();
  }

  // decrement of the quantity from product details page
  void decrement({required PharmacyProductAddModel productDetail}) {
    if (quantityCount <= 1) return;
    quantityCount--;
    setPrescriptionProductMap(productDetail: productDetail);
    notifyListeners();
  }

  /// add locally to list product for approve from productMap in case of prescription
  void addProductsFromMap() {
    pharmacyUserProducts = productMap.values.toList();
    notifyListeners();
  }
  /* ------------------------- UPDATE COMPLETED ORDER ------------------------- */

  Future<void> updateOrderCompletedDetails({
    required PharmacyOrderModel productData,
    required BuildContext context,
    num? commission,
    num? commissionAmt,
  }) async {
    final pharmacyData =
        context.read<AuthenticationProvider>().pharmacyDataFetched;
    String? pharmacyId = FirebaseAuth.instance.currentUser?.uid;
    final data = productData.copyWith(
        orderStatus: 2,
        completedAt: Timestamp.now(),
        commission: commission,
        commissionAmt: commissionAmt);
    final result = await _iOrderFacade.updateProductOrderOnProcessDetails(
        orderId: productData.id ?? '',
        orderProducts: data,
        pharmacyId: pharmacyId ?? '',
        dayTransactionDate: pharmacyData?.dayTransaction ?? '',
        dayTransactionModel: DayTransactionModel(
          commission: data.commissionAmt,
          totalAmount: data.finalAmount,
          offlinePayment: data.paymentType != 'Online' ? data.finalAmount : 0,
          onlinePayment: data.paymentType == 'Online' ? data.finalAmount : 0,
        ));
    result.fold(
      (failure) {
        CustomToast.errorToast(text: failure.errMsg);
        notifyListeners();
      },
      (orderProduct) {
        sendFcmMessage(
            token: orderProduct.userDetails?.fcmToken ?? '',
            body:
                'Your Order by ${orderProduct.pharmacyDetails?.pharmacyName ?? 'Pharmacy'} is completed, We always care about your health.!!',
            title: 'Healthy Cart Order Completed!!');
        CustomToast.sucessToast(text: "Order is sucessfully completed.");
        notifyListeners();
      },
    );
  }

  num calculateOrderCommission(num finalAmount) {
    return (finalAmount * pharmacyTransactionModel!.commission!) / 100;
  }

/* -----------------------------GET COMPLETED ORDER ---------------------------- */
  final TextEditingController searchCompletedBookingsController =
      TextEditingController();
  Future<void> getCompletedOrderDetails({
    required int limit,
  }) async {
    String? pharmacyId = FirebaseAuth.instance.currentUser?.uid;
    fetchloading = true;
    notifyListeners();
    final result = await _iOrderFacade.getCompletedOrderDetails(
        pharmacyId: pharmacyId ?? '',
        initiallimit: limit,
        searchPhoneNumber: searchCompletedBookingsController.text);
    result.fold((failure) {
      CustomToast.errorToast(text: "Couldn't able to get completed orders");
    }, (completedOrders) {
      log(completedOrders.length.toString());
      completedOrderList
          .addAll(completedOrders); //// here we are assigning the doctor
    });
    fetchloading = false;
    notifyListeners();
  }

  void clearCompletedOrderFetchData() {
    completedOrderList.clear();
    _iOrderFacade.clearFetchData();
  }

  void searchCompletedOrders() {
    completedOrderList.clear();
    _iOrderFacade.clearFetchData();
    getCompletedOrderDetails(limit: 5);
    notifyListeners();
  }

/* ------------------------- CANCELLED ORDER SECTION ------------------------ */
  final TextEditingController searchCancelledOrdersController =
      TextEditingController();
  Future<void> getCancelledOrderDetails() async {
    String? pharmacyId = FirebaseAuth.instance.currentUser?.uid;
    fetchloading = true;
    notifyListeners();
    final result = await _iOrderFacade.getCancelledOrderDetails(
        pharmacyId: pharmacyId ?? '',
        searchPhoneNumber: searchCancelledOrdersController.text);
    result.fold((failure) {
       log(failure.errMsg);
      CustomToast.errorToast(text: "Couldn't able to get completed orders");
    }, (cancelledOrders) {
      log(cancelledOrders.length.toString());
      cancelledOrderList
          .addAll(cancelledOrders); //// here we are assigning the doctor
    });
    fetchloading = false;
    notifyListeners();
  }

  void clearCancelledOrderFetchData() {
    cancelledOrderList.clear();
    _iOrderFacade.clearFetchData();
  }

  void searchCancelledOrders() {
    cancelledOrderList.clear();
    _iOrderFacade.clearFetchData();
    getCancelledOrderDetails();
    notifyListeners();
  }

/* --------------------- ORDER COMPLETION STATUS UPDATE --------------------- */

  Future<void> updateOrderStatusToDeliverDetails(
      {required PharmacyOrderModel productData,
      required int value,
      required bool updateValue}) async {
    String? pharmacyId = FirebaseAuth.instance.currentUser?.uid;
    PharmacyOrderModel? data;
    if (value == 1) {
      data = productData.copyWith(
        isOrderPacked: updateValue,
      );
    } else if (value == 2) {
      data = productData.copyWith(isOrderDelivered: updateValue);
    } else {
      data = productData.copyWith(
        isPaymentRecieved: updateValue,
        paymentStatus: updateValue ? 1 : 0,
      );
    }

    final result = await _iOrderFacade.updateProductOrderOnProcessDetails(
      orderId: productData.id ?? '',
      orderProducts: data,
      pharmacyId: pharmacyId ?? '',
    );
    result.fold(
      (failure) {
        CustomToast.errorToast(text: failure.errMsg);
        notifyListeners();
      },
      (orderProduct) {
        if (value == 1 && updateValue == true) {
          CustomToast.sucessToast(text: "Order status updated to packed.");
          sendFcmMessage(
              token: orderProduct.userDetails?.fcmToken ?? '',
              body:
                  'Your Order by ${orderProduct.pharmacyDetails?.pharmacyName ?? 'Pharmacy'} is packed, getting ready for delivery!!',
              title: 'Your Healthy Cart Order Packed!!');
        } else if (value == 1 && updateValue == false) {
          CustomToast.errorToast(text: "Order status updated to not packed.");
        }

        if (value == 2 && updateValue == true) {
          CustomToast.sucessToast(text: "Order is sucessfully delivered.");
          sendFcmMessage(
              token: orderProduct.userDetails?.fcmToken ?? '',
              body:
                  'Your Order by ${orderProduct.pharmacyDetails?.pharmacyName ?? 'Pharmacy'} is delivered !!',
              title: 'Your Healthy Cart Order delivered!!');
        } else if (value == 2 && updateValue == false) {
          CustomToast.errorToast(
              text: "Order status is removed from delivered.");
        }
        if (value == 3 && updateValue == true) {
          CustomToast.sucessToast(
              text: "Order status updated as payment received.");
        } else if (value == 3 && updateValue == false) {
          CustomToast.errorToast(text: "Order payment is not received.");
        }
        notifyListeners();
      },
    );
  }

  /* -------------------------- GET TRANSACTION DATA -------------------------- */
  PharmacyTransactionModel? pharmacyTransactionModel;

  Future<void> getTransactionData() async {
    String? pharmacyId = FirebaseAuth.instance.currentUser?.uid;
    fetchloading = true;
    notifyListeners();
    log('Called transcation fetch');
    final result =
        await _iOrderFacade.getTransactionData(pharmacyId: pharmacyId!);

    result.fold(
      (err) {
        log('error in provider getTransactionData():: ${err.errMsg}');
      },
      (success) {
        // log(success.toString());
        pharmacyTransactionModel = success;
        // log('transaction ID ::: $labId');
      },
    );
    fetchloading = false;

    notifyListeners();
  }
}
