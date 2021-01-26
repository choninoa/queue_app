import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:ke/providers/apiServicesProvider.dart';
import 'package:ke/utils/apiCalls.dart';
import 'package:ke/utils/localizationsKE.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ke/persistence/models/storeModel.dart';
import 'dart:convert';
import 'package:ke/persistence/models/userModel.dart';

class PassDoor extends StatefulWidget {
  @override
  _PassDoorState createState() => _PassDoorState();
}

class _PassDoorState extends State<PassDoor> {
  String result = "";
  ApiCalls apiCalls;
  bool success = true;
  bool trigger = false;
  StoreModel currentStore;

  startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            "#ff6666", "Cancel", true, ScanMode.QR)
        .listen((barcode) {
      if (barcode == null) {
        print('nothing return.');
      } else {
        result = barcode;
        List<String> res = barcode.split("*");
        apiCalls
            .checkReservation(
                idReservation: res[0], idStore: res[1], idUser: res[2])
            .then((value) {
          if (value != null) {
            setState(() {
              success = true;
              trigger = true;
            });
            Future.delayed(Duration(seconds: 2)).then((value) {
              setState(() {
                trigger = false;
              });
            });
          } else {
            setState(() {
              success = false;
              trigger = true;
            });
            Future.delayed(Duration(seconds: 2)).then((value) {
              setState(() {
                trigger = false;
              });
            });
          }
          print("okok: " + value.toString());
        });
      }
    });
  }

  Future _scan() async {
    await Permission.camera.request();
    String barcode = await scanner.scan();
    if (barcode == null) {
      print('nothing return.');
    } else {
      result = barcode;
      List<String> res = barcode.split("*");
      apiCalls
          .checkReservation(
              idReservation: res[0], idStore: res[1], idUser: res[2])
          .then((value) {
        if (value != null) {
          setState(() {
            success = true;
            trigger = true;
          });
          Future.delayed(Duration(seconds: 4)).then((value) {
            setState(() {
              trigger = false;
            });
          });
        } else {
          setState(() {
            success = false;
            trigger = true;
          });
          Future.delayed(Duration(seconds: 4)).then((value) {
            setState(() {
              trigger = false;
            });
          });
        }
        print("okok: " + value.toString());
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apiCalls =
        Provider.of<ApiServicesProvider>(context, listen: false).apiCalls;
    loadShared().then((user) => {getStore(user.idStore)});
  }

  Future<UserModel> loadShared() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    /* String pedidoshared = preferences.getString('orders');
    if (pedidoshared != null) {
      Map<String, dynamic> ma = json.decode(pedidoshared);
      ModeloPedido p = ModeloPedido.fromMap(ma);
      print(("Pedido de shared" + p.state));
    }*/
    return UserModel.fromMap(json.decode(preferences.getString("userobject")));
  }

  getStore(String id) {
    apiCalls.getStoreById(id).then((value) {
      setState(() {
        currentStore = StoreModel.fromMap(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Container(
            height: MediaQuery.of(context).size.height - 50,
            child: Stack(
              children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width - 20,
                          child: Center(
                            child: AutoSizeText(
                              currentStore != null
                                  ? "2 de " +
                                      currentStore.bunchClients.toString()
                                  : "-",
                              style: TextStyle(
                                  fontSize: 80,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo),
                            ),
                          )),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            _scan();
                            /*apiCalls
                      .checkReservation(
                          idReservation: "5fdbe8f0de082560c65248",
                          idStore: "5fce9c6565dbf724a0f7e0fa",
                          idUser: "5fd9039a946c2904f482d8e7")
                      .then((value) {
                    if (value != null) {
                      setState(() {
                        success = true;
                        trigger = true;
                      });
                      Future.delayed(Duration(seconds: 2)).then((value) {
                        setState(() {
                          trigger = false;
                        });
                      });
                    } else {
                      setState(() {
                        success = false;
                        trigger = true;
                      });
                      Future.delayed(Duration(seconds: 2)).then((value) {
                        setState(() {
                          trigger = false;
                        });
                      });
                    }
                    print("okok: " + value.toString());
                  });*/
                          },
                          child: Container(
                              height: MediaQuery.of(context).size.width / 2,
                              width: MediaQuery.of(context).size.width / 2,
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 1.0,
                                  spreadRadius: 1.0,
                                  offset: Offset(
                                    1.0,
                                    1.0,
                                  ),
                                )
                              ], shape: BoxShape.circle, color: Colors.indigo),
                              child: Icon(
                                CupertinoIcons.qrcode,
                                size: MediaQuery.of(context).size.width / 3,
                                color: Colors.white,
                              )),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          CupertinoIcons.arrow_right_circle_fill,
                          color: Colors.indigo,
                          size: 100,
                        ),
                      )
                    ]),
                AnimatedPositioned(
                  top: trigger ? 20 : -100,
                  left: MediaQuery.of(context).size.width / 2 -
                      MediaQuery.of(context).size.width / 4 -
                      10,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.ease,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    //height: 60,
                    width: MediaQuery.of(context).size.width / 2,
                    decoration: BoxDecoration(
                        color: success ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(40)),
                    child: Center(
                        child: AutoSizeText(
                      success
                          ? LocalizationsKE.of(context).success
                          : LocalizationsKE.of(context).error,
                      maxLines: 1,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
