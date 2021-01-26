class UserModel {
  String id;
  String name;
  String first_name;
  String last_name;
  String email;
  String username;
  String phone;
  String address;
  String image;
  String rol;
  String idStore;
  String state;

  UserModel(
      {this.id,
      this.name,
      this.first_name,
      this.last_name,
      this.email,
      this.username,
      this.phone,
      this.address,
      this.image,
      this.idStore,
      this.state,
      this.rol});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      '_id': id,
      'fullname': name,
      'first_name': first_name,
      'last_name': last_name,
      'email': email,
      'username': username,
      'phone': phone,
      'address': address,
      'image': image,
      'rol': rol,
      'state': state,
      'idStore': idStore,
    };
    return map;
  }

  UserModel.fromMap(Map<String, dynamic> map) {
    id = map['_id'].toString();
    name = map['fullname'];
    first_name = map['first_name'];
    last_name = map['last_name'];
    email = map['email'];
    username = map['username'];
    phone = map['phone'];
    address = map['address'];
    image = map['avatar'];
    rol = map['rol'];
    idStore = map['idStore'];
    state = map['state'];
  }
}
