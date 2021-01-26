import 'package:ke/persistence/models/reservationModel.dart';

class ReservationRepository {
  final List<ReservationModel> reservations;
  ReservationRepository({this.reservations});

  factory ReservationRepository.fromJson(Map<String,dynamic> json) {
    return ReservationRepository(reservations: parseStores(json));
  }

  static List<ReservationModel> parseStores(parseoffers) {
    var lista = parseoffers['reservations'] as List;
    List<ReservationModel> all =
        lista.map((data) => ReservationModel.fromMap(data)).toList();
    return all;
  }
}
