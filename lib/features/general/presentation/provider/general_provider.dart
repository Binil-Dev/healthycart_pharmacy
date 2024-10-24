import 'dart:async';
import 'package:flutter/material.dart';
import 'package:healthycart_pharmacy/features/general/data/i_general_facade.dart';
import 'package:healthycart_pharmacy/features/general/data/model/general_model.dart';
import 'package:injectable/injectable.dart';


@injectable
class GeneralProvider extends ChangeNotifier {
  GeneralProvider(this.iGeneralFacade);
  final IGeneralFacade iGeneralFacade;
  GeneralModel? generalModel;

  Future<void> fetchData() async {
    final completer = Completer<void>();
    final result = iGeneralFacade.fetchData();
    result.listen((event) {
      generalModel = event;
      notifyListeners();
      if (!completer.isCompleted) {
        completer.complete();
      }
    }, onError: (error) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    });
    await completer.future;
  }
}
