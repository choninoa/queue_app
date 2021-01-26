class ReservationModel {
  String id;
  String date;
  String idUser;
  String idStore;
  String nameStore;
  int cant;
  String status;

  ReservationModel({
    this.id,
    this.date,
    this.idUser,
    this.idStore,
    this.nameStore,
    this.cant,
    this.status,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "id": id,
      "date": date,
      "idUser": idUser,
      "idStore": idStore,
      "storeName": nameStore,
      "status": status,
      "cant": cant,
    };
    return map;
  }

  ReservationModel.fromMap(Map<String, dynamic> map) {
    id = map['_id'];
    date = map['date'];
    idUser = map['idUser'];
    idStore = map['idStore'];
    nameStore = map['storeName'];
    status = map['status'];
    cant = map['cant'];
  }
}
