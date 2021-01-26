class StoreModel {
  String id;
  String name;
  int bunchClients;
  int estimateMinutes;
  String status;
  String address;
  String phone;
  String type;
  double latitude;
  double longitude;
  String openAt;
  String closedAt;
  double distance;

  StoreModel(
      {this.id,
      this.name,
      this.bunchClients,
      this.estimateMinutes,
      this.status,
      this.address,
      this.phone,
      this.type,
      this.latitude,
      this.longitude,
      this.openAt,
      this.closedAt,
      this.distance});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "id": id,
      "name": name,
      "bunchClients": bunchClients,
      "estimateMinutes": estimateMinutes,
      "status": status,
      "type": type,
      "phone": phone,
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "openAt": openAt,
      "closedAt": closedAt,
    };
    return map;
  }

  StoreModel.fromMap(Map<String, dynamic> map) {
    id = map['_id'];
    name = map['name'];
    bunchClients = map['bunchClients'];
    estimateMinutes = map['estimateMinutes'];
    status = map['status'];
    address = map['address'];
    phone = map['phone'];
    type = map['type'];
    openAt = map['openAt'];
    closedAt = map['closedAt'];
    latitude = map['gps']['lat'];
    longitude = map['gps']['lon'];
  }
}
