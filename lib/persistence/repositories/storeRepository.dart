import 'package:ke/persistence/models/storeModel.dart';

class StoreRepository {
  final List<StoreModel> stores;
  StoreRepository({this.stores});

  factory StoreRepository.fromJson(List<dynamic> json) {
    return StoreRepository(stores: parseStores(json));
  }

  static List<StoreModel> parseStores(parseoffers) {
    var lista = parseoffers as List;
    List<StoreModel> all =
        lista.map((data) => StoreModel.fromMap(data)).toList();

    return all;
  }
}
