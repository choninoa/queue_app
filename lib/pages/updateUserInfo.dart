import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ke/persistence/models/userModel.dart';
import 'package:ke/providers/apiServicesProvider.dart';
import 'package:ke/providers/authServices.dart';
import 'package:ke/utils/apiCalls.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateUserInfo extends StatefulWidget {
  final String toUpdate;
  final UserModel user;
  UpdateUserInfo({this.toUpdate, this.user});
  @override
  _UpdateUserInfoState createState() => _UpdateUserInfoState();
}

class _UpdateUserInfoState extends State<UpdateUserInfo> {
  TextEditingController _name;
  TextEditingController _lastname;
  TextEditingController _password;
  TextEditingController _phone;
  TextEditingController _city;
  TextEditingController _repassword;
  TextEditingController _repassword1;
  String selectedRadio = "";
  ApiCalls apiCalls;
  bool sending = false;
  String _gender = "";
  AuthServices _auth;

  setSelectedRadio(String val) {
    setState(() {
      selectedRadio = val;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apiCalls =
        Provider.of<ApiServicesProvider>(context, listen: false).apiCalls;
    _name = TextEditingController(text: widget.user.first_name);
    _lastname = TextEditingController(text: widget.user.last_name);
    _phone = TextEditingController(text: widget.user.phone);
    _city = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthServices>(context);
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: Icon(CupertinoIcons.back,color: Colors.black,), onPressed: ()=>Navigator.pop(context)),
          centerTitle: true,
          title: Text(
            "Actualizar",
            style: TextStyle(color: Colors.indigo),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Stack(
              children: [
                ListView(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    widget.toUpdate == "name"
                        ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black.withOpacity(.1),
                                            blurRadius: 10,
                                            spreadRadius: 1)
                                      ],
                                      borderRadius: BorderRadius.circular(25)),
                                  child: TextFormField(
                                    controller: _name,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            CupertinoIcons.person_alt_circle,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                        hintText: "Nombre"),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black.withOpacity(.1),
                                            blurRadius: 10,
                                            spreadRadius: 1)
                                      ],
                                      borderRadius: BorderRadius.circular(25)),
                                  child: TextFormField(
                                    controller: _lastname,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                              CupertinoIcons.person_alt_circle,
                                              color: Colors.indigo),
                                        ),
                                        hintText: "Apellidos"),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : widget.toUpdate == "phone"
                            ? Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(.1),
                                                blurRadius: 10,
                                                spreadRadius: 1)
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(25)),
                                      child: TextFormField(
                                        controller: _phone,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            prefixIcon: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Icon(
                                                  CupertinoIcons.phone_circle,
                                                  color: Colors.indigo),
                                            ),
                                            hintText: "Teléfono"),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : widget.toUpdate == "city"
                                ? Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(.1),
                                                    blurRadius: 10,
                                                    spreadRadius: 1)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(25)),
                                          child: TextFormField(
                                            controller: _city,
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                prefixIcon: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                      CupertinoIcons.house,
                                                      color: Colors.indigo),
                                                ),
                                                hintText: "Dirección"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(.1),
                                                    blurRadius: 10,
                                                    spreadRadius: 1)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(25)),
                                          child: TextFormField(
                                            controller: _repassword,
                                            obscureText: true,
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                prefixIcon: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                      CupertinoIcons.eye,
                                                      color: Colors.indigo),
                                                ),
                                                hintText: "Contraseña nueva"),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(.1),
                                                    blurRadius: 10,
                                                    spreadRadius: 1)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(25)),
                                          child: TextFormField(
                                            obscureText: true,
                                            controller: _repassword1,
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                prefixIcon: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                      CupertinoIcons.eye,
                                                      color: Colors.indigo),
                                                ),
                                                hintText:
                                                    "Verifica la contraseña"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                    widget.toUpdate == "password"
                        ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(.1),
                                        blurRadius: 10,
                                        spreadRadius: 1)
                                  ],
                                  borderRadius: BorderRadius.circular(25)),
                              child: TextFormField(
                                controller: _password,
                                obscureText: true,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(CupertinoIcons.eye,
                                          color: Colors.indigo),
                                    ),
                                    hintText: "Contraseña"),
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 40,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          sending = true;
                        });
                        if (widget.toUpdate == "password") {
                          /* apiCalls
                              .changePassword(_password.text, _repassword.text,
                                  _repassword1.text)
                              .then((value) {
                            if (value != null) {
                              Navigator.pop(context, "updated");
                            } else {
                              setState(() {
                                sending = true;
                              });
                            }
                          });*/
                        } else {
                          Map<String, dynamic> data = new Map();
                          UserModel profile = UserModel(
                            first_name: _auth.currentUser.user.first_name,
                            last_name: _auth.currentUser.user.last_name,
                            phone: _auth.currentUser.user.phone,
                          );
                          if (widget.toUpdate == "name") {
                            data["first_name"] = _name.text;
                            data["last_name"] = _lastname.text;
                            data["sex"] = _gender;
                          } else if (widget.toUpdate == "phone") {
                            data["phone"] = _phone.text;
                          } else if (widget.toUpdate == "city") {
                            data["address"] = {"address_1": _city.text};
                          }
                          /*apiCalls
                              .editUserInfo(_auth.currentUser.user.uuid, data)
                              .then((value) async {
                            if (value != null) {
                              SharedPreferences preferences =
                                  await SharedPreferences.getInstance();
                              ProfileModel user = ProfileModel.fromMap(value);
                              _auth.currentUser.user.first_name =
                                  user.first_name;
                              _auth.currentUser.user.last_name = user.last_name;
                              _auth.currentUser.user.gender = user.gender;
                              _auth.currentUser.user.full_address =
                                  user.full_address;
                              _auth.currentUser.user.phone = user.phone;

                              preferences?.setString(
                                  "userobject", json.encode(user.toMap()));
                              Navigator.pop(context, "updated");
                            } else {
                              setState(() {
                                sending = true;
                              });
                            }
                          });*/
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 4,
                        ),
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.indigo),
                        child: Center(
                          child: Text(
                            "Actualizar",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                sending
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container()
              ],
            )));
  }

  void _showExitBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setBottom) {
            return Container(
              height: MediaQuery.of(context).size.height / 3,
              color: Color(0xFF737373),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      )),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Salir",
                        style: TextStyle(),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Está seguro que desea salir?",
                        style: TextStyle(),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              height: 50,
                              margin:
                                  EdgeInsets.only(right: 10, left: 10, top: 20),
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(30)),
                              child: Center(
                                child: Text(
                                  "Aceptar",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              height: 50,
                              margin:
                                  EdgeInsets.only(right: 10, left: 10, top: 20),
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(30)),
                              child: Center(
                                child: Text(
                                  "Cancelar",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  )),
            );
          });
        });
  }
}
