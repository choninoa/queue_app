import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ke/main.dart';
import 'package:ke/pages/MapPage.dart';
import 'package:ke/pages/ReservationsPage.dart';
import 'package:ke/pages/UserInfo.dart';
import 'package:ke/pages/createStore.dart';
import 'package:ke/providers/authServices.dart';
import 'package:ke/providers/currentPositionProvider.dart';
import 'package:provider/provider.dart';
import 'pages/passDoor.dart';
import 'package:ke/utils/localizationsKE.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  int current = 1;
  double pos = 48;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AuthServices _auth = Provider.of<AuthServices>(context);
    CurrentPositionProvider _currentPosition =
        Provider.of<CurrentPositionProvider>(context);
    if (current == 1) {
      pos = MediaQuery.of(context).size.width / 2 - 5;
    }
    return Scaffold(
        body: Stack(children: [
      current == 0
          ? _auth.currentUser.user.rol == "MODERATOR"
              ? PassDoor()
              : _auth.currentUser.user.rol == "ADMIN"
                  ? CreateStore()
                  : ReservationsPage()
          : current == 1
              ? MapPage(
                  title: "Virtual KE",
                  language: LocalizationsKE.of(context).locale.toString(),
                )
              : AccountInfo(),
      Positioned(
        bottom: 0,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 55,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 55,
                  color: Colors.indigo,
                ),
              ),
              /*AnimatedPositioned(
                left: pos,
                duration: Duration(milliseconds: 200),
                curve: Curves.ease,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20))),
                ),
              ),*/
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /* IconButton(
                        icon: Icon(
                            _auth.currentUser.user.rol == "MODERATOR"
                                ? CupertinoIcons.qrcode
                                : CupertinoIcons.archivebox,
                            color: Colors.white),
                        onPressed: () {
                          setState(() {
                            current = 0;
                            pos = 48;
                          });
                        }),*/
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            current = 0;
                            pos = 48;
                          });
                        },
                        child: Image.asset("assets/images/Planification.png"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: InkWell(
                        onTap: () {
                          if (current == 1) {
                            _currentPosition.setCurrent(true);
                          }
                          setState(() {
                            current = 1;
                            pos = MediaQuery.of(context).size.width / 2 - 5;
                          });
                        },
                        child: Image.asset("assets/images/pinmapKe.png"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            current = 2;
                            pos = MediaQuery.of(context).size.width - 59;
                          });
                        },
                        child: Image.asset("assets/images/Profile.png"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    ]));
  }
}
