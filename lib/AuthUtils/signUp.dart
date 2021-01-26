import 'dart:io';
import 'package:ke/utils/apiCalls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert' show json, base64, ascii;
import 'package:ke/providers/currentUser.dart';
import 'package:dio/dio.dart';
import 'package:ke/providers/apiServicesProvider.dart';
import 'package:ke/utils/localizationsKE.dart';
import 'package:ke/persistence/models/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ke/wrapper.dart';
import 'package:ke/providers/authServices.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _username = new TextEditingController();
  TextEditingController _fullname = new TextEditingController();
  TextEditingController _password = new TextEditingController();
  TextEditingController _password2 = new TextEditingController();
  TextEditingController _direccion = new TextEditingController();
  TextEditingController _telefono = new TextEditingController();
  TextEditingController _correo = new TextEditingController();
  ApiCalls apiCalls;
  String sexo = "";
  PageController controller = PageController();
  int _currentpage = 0;
  final _formKey = GlobalKey<FormState>();
  bool contact = false;
  List<String> annadidos = new List();

  bool checkingUser = false;

  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apiCalls =
        Provider.of<ApiServicesProvider>(context, listen: false).apiCalls;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.indigo,
          resizeToAvoidBottomInset: false,
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Form(
              key: _formKey,
              child: Stack(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 20, bottom: 20),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 1.0,
                            spreadRadius: 1.0,
                            offset: Offset(
                              1.0,
                              1.0,
                            ),
                          )
                        ],
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white),
                    child: ListView(
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        Center(
                          child: Text(
                            LocalizationsKE.of(context).registrarcuenta,
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.grey.withOpacity(0.1)
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )),
                          child: TextField(
                            //style: TextStyle(color: Colors.white),
                            controller: _fullname,
                            cursorColor: Colors.blue,
                            decoration: InputDecoration(
                              labelStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              labelText: LocalizationsKE.of(context).nombre,
                              suffixIcon: Icon(
                                Icons.clear,
                                color: Colors.grey,
                                size: 20.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.grey.withOpacity(0.1)
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )),
                          child: TextField(
                            //style: TextStyle(color: Colors.white),
                            controller: _username,
                            cursorColor: Colors.blue,
                            decoration: InputDecoration(
                              labelStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              labelText: LocalizationsKE.of(context).usuario,
                              suffixIcon: Icon(
                                Icons.clear,
                                color: Colors.grey,
                                size: 20.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.grey.withOpacity(0.1)
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )),
                          child: TextField(
                            // style: TextStyle(color: Colors.white),
                            controller: _correo,
                            cursorColor: Colors.blue,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              labelText: LocalizationsKE.of(context).correo,
                              suffixIcon: Icon(
                                Icons.clear,
                                color: Colors.grey,
                                size: 20.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.grey.withOpacity(0.1)
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )),
                          child: TextField(
                            //style: TextStyle(color: Colors.white),
                            controller: _telefono,
                            keyboardType: TextInputType.number,
                            cursorColor: Colors.blue,
                            decoration: InputDecoration(
                              labelStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              labelText: LocalizationsKE.of(context).telefono,
                              suffixIcon: Icon(
                                Icons.clear,
                                color: Colors.grey,
                                size: 20.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.grey.withOpacity(0.1)
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )),
                          child: TextField(
                            //style: TextStyle(color: Colors.white),
                            controller: _direccion,
                            cursorColor: Colors.blue,
                            decoration: InputDecoration(
                              labelStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              labelText: LocalizationsKE.of(context).direccion,
                              suffixIcon: Icon(
                                Icons.clear,
                                color: Colors.grey,
                                size: 20.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.grey.withOpacity(0.1)
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )),
                          child: TextField(
                            //style: TextStyle(color: Colors.white),
                            controller: _password,
                            cursorColor: Colors.blue,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              labelText: LocalizationsKE.of(context).contrasena,
                              suffixIcon: Icon(
                                Icons.clear,
                                color: Colors.grey,
                                size: 20.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.grey.withOpacity(0.1)
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )),
                          child: TextField(
                            //style: TextStyle(color: Colors.white),
                            controller: _password2,
                            cursorColor: Colors.blue,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              labelText:
                                  LocalizationsKE.of(context).repetircontrasena,
                              suffixIcon: Icon(
                                Icons.clear,
                                color: Colors.grey,
                                size: 20.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              checkingUser = true;
                            });
                            registerUser();
                          },
                          child: Center(
                            child: Container(
                              width: 500,
                              height: 60,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.green),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                    child: Text(
                                  LocalizationsKE.of(context).registrar,
                                  style: TextStyle(color: Colors.white),
                                )),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  checkingUser
                      ? Center(
                          child: Container(
                            height: 80,
                            width: 80,
                            child: Theme(
                                data: ThemeData(accentColor: Colors.blue),
                                child: CircularProgressIndicator()),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          )),
    );
  }

  registerUser() async {
    apiCalls
        .registerUser(
      email: _correo.text,
      name: _fullname.text,
      username: _username.text,
      address: _direccion.text,
      phone: _telefono.text,
      password: _password.text,
    )
        .then((value) {
      apiCalls.logIn(_username.text, _password.text).then((value) async {
        setState(() {
          checkingUser = false;
        });
        if (value != null) {
          print(value.toString());
          if (value.statusCode == 201) {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            UserModel user = UserModel.fromMap(value.data["user"]);
            var result = await Provider.of<AuthServices>(context, listen: false)
                .loginUser(user: json.encode(user.toMap()));
            preferences?.setString("userobject", json.encode(user.toMap()));
            preferences?.setBool("isLoggedIn", true);
            preferences?.setString("useruuid", user.id);
            preferences.setString("token", value.data["access_token"]);
            Navigator.of(context)
                .push(CupertinoPageRoute(builder: (context) => Wrapper()));
          }
        }
      });
      //apiCalls.logIn(usuario, pass)
    });
  }
}
