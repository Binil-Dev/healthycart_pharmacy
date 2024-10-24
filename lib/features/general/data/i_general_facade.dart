
import 'package:healthycart_pharmacy/features/general/data/model/general_model.dart';

abstract class IGeneralFacade {
  Stream<GeneralModel?> fetchData() async* {
    throw UnimplementedError("fetchData() Not implemented");
  }
}
