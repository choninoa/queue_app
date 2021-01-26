import 'dart:io';
import 'package:ke/persistence/models/storeModel.dart';
import 'package:ke/utils/apiCalls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';
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

class CreateStore extends StatefulWidget {
  double latitude;
  double longitude;
  String direccion;
  CreateStore({this.latitude, this.longitude, this.direccion});
  @override
  _CreateStoreState createState() => _CreateStoreState();
}

class _CreateStoreState extends State<CreateStore> {
  TextEditingController _coordinates = new TextEditingController();
  TextEditingController _fullname = new TextEditingController();
  TextEditingController _bunchClients = new TextEditingController();
  TextEditingController _estimateTime = new TextEditingController();
  TextEditingController _direccion;
  String _openAt = "";
  String _closeAt = "";
  ApiCalls apiCalls;
  String sexo = "";
  PageController controller = PageController();
  int _currentpage = 0;
  final _formKey = GlobalKey<FormState>();
  bool contact = false;
  List<String> annadidos = new List();
  ScrollController _scrollController = new ScrollController();

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
    _direccion = TextEditingController(
        text: widget.direccion != null ? widget.direccion : "");
    _coordinates = TextEditingController(
        text: widget.latitude != null
            ? "${widget.latitude}, ${widget.longitude}"
            : "");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          //backgroundColor: Colors.indigo,
          resizeToAvoidBottomInset: false,
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Form(
              key: _formKey,
              child: Stack(
                children: <Widget>[
                  Container(
                    //margin: EdgeInsets.only(top: 20, bottom: 20),
                    //padding: EdgeInsets.all(10),

                    child: Scrollbar(
                      controller: _scrollController,
                      isAlwaysShown: true,
                      child: ListView(
                        children: [
                          SizedBox(
                            height: 40,
                          ),
                          Center(
                            child: Text(
                              "Registrar nueva tienda",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
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
                                labelText: "Nombre",
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
                                labelText:
                                    LocalizationsKE.of(context).direccion,
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
                              controller: _coordinates,
                              cursorColor: Colors.blue,
                              decoration: InputDecoration(
                                labelStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                labelText: "Coordenadas",
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
                              controller: _bunchClients,
                              cursorColor: Colors.blue,
                              decoration: InputDecoration(
                                labelStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                labelText: "Cantidad de clientes",
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
                              controller: _estimateTime,
                              cursorColor: Colors.blue,
                              decoration: InputDecoration(
                                labelStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                labelText: "Tiempo estimado",
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
                            child: Container(
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
                                child: Column(
                                  children: [
                                    Text("Hora de Apertura"),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      height: 100,
                                      child: CupertinoDatePicker(
                                          use24hFormat: true,
                                          mode: CupertinoDatePickerMode.time,
                                          onDateTimeChanged: (value) {
                                            setState(() {
                                              _openAt = value
                                                      .toLocal()
                                                      .toIso8601String() +
                                                  "Z";
                                            });
                                          }),
                                    )
                                  ],
                                )),
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
                              child: Column(
                                children: [
                                  Text("Hora de Cierre"),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    height: 100,
                                    child: CupertinoDatePicker(
                                        use24hFormat: true,
                                        mode: CupertinoDatePickerMode.time,
                                        onDateTimeChanged: (value) {
                                          setState(() {
                                            _closeAt = value
                                                    .toLocal()
                                                    .toIso8601String() +
                                                "Z";
                                          });
                                        }),
                                  )
                                ],
                              )),
                          SizedBox(
                            height: 40,
                          ),
                          GestureDetector(
                            onTap: () async {
                              createStore();
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

  createStore() async {
    print("OpenAt:" + _openAt);
    print("CloseAt:" + _closeAt);
    setState(() {
      checkingUser = true;
    });
    StoreModel store = new StoreModel(
        name: _fullname.text,
        address: _direccion.text,
        bunchClients: int.parse(_bunchClients.text),
        estimateMinutes: int.parse(_estimateTime.text),
        openAt: _openAt,
        closedAt: _closeAt,
        latitude: widget.latitude,
        longitude: widget.longitude);
    print("QAbre" + _openAt);
    apiCalls.createStore(store).then((value) {
      setState(() {
        checkingUser = false;
      });
      Navigator.pop(context);
    });
  }
}
