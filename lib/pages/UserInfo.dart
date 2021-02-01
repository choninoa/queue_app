import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ke/pages/updateUserInfo.dart';
import 'package:ke/providers/utilsProvider.dart';
import 'package:ke/utils/mapTypes.dart';
import 'package:provider/provider.dart';
import 'package:ke/providers/apiServicesProvider.dart';
import 'package:ke/providers/authServices.dart';
import 'package:ke/persistence/repositories/userRepositoryFromMemory.dart';
import 'package:ke/utils/apiCalls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ke/utils/localizationsKE.dart';

class AccountInfo extends StatefulWidget {
  @override
  _AccountInfoState createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  SharedPreferences prefs;
  UserRepositoryFromMemory user;
  ApiCalls apiCalls;
  AuthServices _auth;
  final key = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apiCalls =
        Provider.of<ApiServicesProvider>(context, listen: false).apiCalls;
    getShared();
  }

  getShared() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      String objectuser = prefs.getString("userobject");
      if (objectuser != null) {
        user = new UserRepositoryFromMemory.fromJson(json.decode(objectuser));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthServices>(context);
    UtilsProvider _utils = Provider.of<UtilsProvider>(context);
    return Scaffold(
      key: key,
      appBar: AppBar(
        leading: Container(),
        centerTitle: true,
        title: Text(
          LocalizationsKE.of(context).perfil,
          style: TextStyle(
              color: _utils.showCurrent() == MapTypes.REGULAR
                  ? Colors.indigo
                  : Colors.white),
        ),
        backgroundColor: _utils.showCurrent() == MapTypes.RED
            ? Colors.red
            : _utils.showCurrent() == MapTypes.BLUE
                ? Colors.blue
                : Colors.white,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () {
              //_auth.logout();
              _showExitBottomSheet(context);
            },
            child: Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(right: 10),
              height: 40,
              width: 40,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.indigo),
              child: Center(
                child: Icon(Icons.logout),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: _utils.showCurrent() != MapTypes.REGULAR
            ? BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(
                      _utils.showCurrent() == MapTypes.RED
                          ? "assets/images/red-map.png"
                          : "assets/images/blue-map.png",
                    )))
            : BoxDecoration(),
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            _auth.currentUser.user.image != null
                ? CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(_auth.currentUser.user.image),
                  )
                : CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage("assets/images/shopping.png"),
                  ),
            SizedBox(
              height: 10,
            ),
            _auth.currentUser.user.username != null
                ? Center(
                    child: Text(
                    _auth.currentUser.user.username,
                    style: TextStyle(
                        color: _utils.showCurrent() == MapTypes.REGULAR
                            ? Colors.indigo
                            : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ))
                : Container(),
            SizedBox(
              height: 20,
            ),
            Container(
                margin: EdgeInsets.only(bottom: 10),
                alignment: Alignment.center,
                child: Text(
                  LocalizationsKE.of(context).informacion,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: _utils.showCurrent() == MapTypes.REGULAR
                          ? Colors.indigo
                          : Colors.white),
                )),
            _auth.currentUser.user.name != null && _auth.user.user.name != ""
                ? GestureDetector(
                    /* onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) => UpdateUserInfo(
                                  user: _auth.currentUser.user,
                                  toUpdate: "name",
                                )))
                        .then((value) {
                      if (value == "updated") {
                        setState(() {});
                      }
                    }),*/
                    child: actionSection(
                        context,
                        Icon(CupertinoIcons.person_alt_circle,
                            color: Colors.indigo),
                        _auth.currentUser.user.name),
                  )
                : Container(),
            _auth.currentUser.user.email != null &&
                    _auth.currentUser.user.email != ""
                ? GestureDetector(
                    /* onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) => UpdateUserInfo(
                                      user: _auth.currentUser.user,
                                      toUpdate: "phone",
                                    )))
                            .then((value) {
                          if (value == "updated") {}
                        }),*/
                    child: actionSection(
                        context,
                        Icon(CupertinoIcons.mail, color: Colors.indigo),
                        _auth.currentUser.user.email))
                : Container(),
            _auth.currentUser.user.phone != null &&
                    _auth.currentUser.user.phone != ""
                ? GestureDetector(
                    /* onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) => UpdateUserInfo(
                                      user: _auth.currentUser.user,
                                      toUpdate: "phone",
                                    )))
                            .then((value) {
                          if (value == "updated") {}
                        }),*/
                    child: actionSection(
                        context,
                        Icon(CupertinoIcons.phone, color: Colors.indigo),
                        _auth.currentUser.user.phone))
                : Container(),
            _auth.user.user.address != null && _auth.user.user.address != ""
                ? GestureDetector(
                    /* onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) => UpdateUserInfo(
                                      user: _auth.currentUser.user,
                                      toUpdate: "city",
                                    )))
                            .then((value) {
                          if (value == "updated") {
                            setState(() {});
                          }
                        }),*/
                    child: actionSection(
                        context,
                        Icon(CupertinoIcons.house, color: Colors.indigo),
                        _auth.currentUser.user.address))
                : Container(),
            Container(
                margin: EdgeInsets.only(bottom: 10),
                alignment: Alignment.center,
                child: Text(
                  LocalizationsKE.of(context).general,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: _utils.showCurrent() == MapTypes.REGULAR
                          ? Colors.indigo
                          : Colors.white),
                )),
            GestureDetector(
              /* onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => UpdateUserInfo(
                            user: _auth.currentUser.user,
                            toUpdate: "password",
                          )))
                  .then((value) {
                if (value == "updated") {
                  setState(() {});
                }
              }),*/
              child: actionSection(
                  context,
                  Icon(CupertinoIcons.eye, color: Colors.indigo),
                  LocalizationsKE.of(context).contrasena),
            ),
            actionSection(
                context,
                Icon(CupertinoIcons.lock_circle, color: Colors.indigo),
                LocalizationsKE.of(context).privacidad),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(LocalizationsKE.of(context).themecolor,
                  style: TextStyle(
                      color: _utils.showCurrent() == MapTypes.REGULAR
                          ? Colors.indigo
                          : Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () => _utils.setCurrent(MapTypes.BLUE),
                  child: Container(
                    decoration: _utils.showCurrent() == MapTypes.BLUE
                        ? BoxDecoration(
                            color: Colors.blue, border: Border.all())
                        : BoxDecoration(color: Colors.blue),
                    height: 50,
                    width: 50,
                  ),
                ),
                InkWell(
                  onTap: () => _utils.setCurrent(MapTypes.RED),
                  child: Container(
                    decoration: _utils.showCurrent() == MapTypes.RED
                        ? BoxDecoration(color: Colors.red, border: Border.all())
                        : BoxDecoration(color: Colors.red),
                    height: 50,
                    width: 50,
                  ),
                ),
                InkWell(
                  onTap: () => _utils.setCurrent(MapTypes.REGULAR),
                  child: Container(
                    decoration: _utils.showCurrent() == MapTypes.REGULAR
                        ? BoxDecoration(
                            color: Colors.white, border: Border.all())
                        : BoxDecoration(color: Colors.white),
                    height: 50,
                    width: 50,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 100,
            )
          ],
        ),
      ),
    );
  }

  Container actionSection(BuildContext context, Icon icon, String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      width: MediaQuery.of(context).size.width / 2,
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.1),
                blurRadius: 10,
                spreadRadius: 1)
          ],
          borderRadius: BorderRadius.circular(25)),
      child: ListTile(
          leading: Container(
            height: 40,
            child: icon,
          ),
          title: Text(text),
          trailing: Icon(Icons.keyboard_arrow_right)),
    );
  }

  void _showExitBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(40.0)),
        ),
        backgroundColor: Colors.white,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setBottom) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: MediaQuery.of(context).size.height / 3,
              //color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AutoSizeText(
                    LocalizationsKE.of(context).salir,
                    style: TextStyle(fontSize: 22),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          prefs.setBool("isLoggedIn", false);

                          //apiCalls.logOut(_token.getRefresh());
                          _auth.logout();
                          Navigator.pop(context);
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          height: 40,
                          margin: EdgeInsets.only(right: 10, left: 10, top: 20),
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(30)),
                          child: Center(
                            child: Text(
                              LocalizationsKE.of(context).aceptar,
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
                          height: 40,
                          margin: EdgeInsets.only(right: 10, left: 10, top: 20),
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(30)),
                          child: Center(
                            child: Text(
                              LocalizationsKE.of(context).cancelar,
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
              ),
            );
          });
        });
  }
}
