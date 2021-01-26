import 'package:intl/date_symbol_data_local.dart';
import 'package:ke/AuthUtils/signUp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ke/persistence/models/userModel.dart';
import 'package:ke/wrapper.dart';
import 'package:provider/provider.dart';
import 'dart:convert' show json, base64, ascii;
import 'package:ke/providers/currentUser.dart';
import 'package:ke/providers/authServices.dart';
import 'package:ke/providers/apiServicesProvider.dart';
import 'package:ke/utils/apiCalls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ke/utils/localizationsKE.dart';

class LogIn extends StatefulWidget {
  LogIn({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  TextEditingController _username = new TextEditingController();
  TextEditingController _password = new TextEditingController();
  TextEditingController _confirmationemail = new TextEditingController();
  TextEditingController _apiaddress = new TextEditingController();

  bool checkingUser = false;
  CurrentUser _currentUser;
  AuthServices _auth;
  ApiCalls apiCalls;
  bool sending = false;
  bool successCall = true;
  final _formKey = GlobalKey<FormState>();
  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  void passwordRecovery(context, title, text) => showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setBottom) {
            return Container(
              height: MediaQuery.of(context).size.height / 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: successCall
                    ? sending
                        ? CupertinoActivityIndicator(
                            radius: 40,
                          )
                        : ListView(
                            //mainAxisAlignment: MainAxisAlignment.center,
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Introduce tu e-mail debajo para reestablecer tu contraseña?",
                                style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey[200]),
                                padding: EdgeInsets.only(left: 10),
                                child: TextFormField(
                                  controller: _confirmationemail,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintStyle:
                                          TextStyle(color: Colors.grey[500]),
                                      hintText: '   e-mail'),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              SizedBox(
                                width: 320.0,
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  onPressed: () {
                                    setBottom(() {
                                      sending = true;
                                    });
                                    apiCalls
                                        .passwordChangeRequest(
                                            _confirmationemail.text)
                                        .then((value) {
                                      if (value != null) {
                                        if (value.statusCode == 200) {}
                                      } else {
                                        setBottom(() {
                                          setState(() {
                                            sending = false;
                                            successCall = false;
                                          });
                                        });
                                      }
                                    });
                                  },
                                  child: Text(
                                    "Reestablecer",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(
                                width: 320.0,
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  onPressed: () {
                                    setBottom(() {
                                      sending = true;
                                    });
                                  },
                                  child: Text(
                                    LocalizationsKE.of(context).cancelar,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          )
                    : Container(
                        color: Colors.red,
                        child: Text("Error"),
                      ),
              ),
            );
          }),
        );
      });

  void setAPIAddress(context) => showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setBottom) {
            return Container(
              height: MediaQuery.of(context).size.height / 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: successCall
                    ? sending
                        ? CupertinoActivityIndicator(
                            radius: 40,
                          )
                        : ListView(
                            //mainAxisAlignment: MainAxisAlignment.center,
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Introduce dirección de API",
                                style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey[200]),
                                padding: EdgeInsets.only(left: 10),
                                child: TextFormField(
                                  controller: _apiaddress,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintStyle:
                                          TextStyle(color: Colors.grey[500]),
                                      hintText: '  API'),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              SizedBox(
                                width: 320.0,
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  onPressed: () async {
                                    SharedPreferences sharedPreferences =
                                        await SharedPreferences.getInstance();
                                    sharedPreferences.setString(
                                        'apiaddress', _apiaddress.text);
                                    setState(() {
                                      apiCalls = new ApiCalls();
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: Text(
                                    "Cambiar",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          )
                    : Container(
                        color: Colors.red,
                        child: Text("Error"),
                      ),
              ),
            );
          }),
        );
      });

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apiCalls =
        Provider.of<ApiServicesProvider>(context, listen: false).apiCalls;
    initializeDateFormatting();
  }

  authenticate() {
    if (_formKey.currentState.validate()) {
      setState(() {
        checkingUser = true;
      });
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
    }
  }

  @override
  Widget build(BuildContext context) {
    _currentUser = Provider.of<CurrentUser>(context);
    _auth = Provider.of<AuthServices>(context);

    _formKey;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.indigo,
        body: Stack(
          children: [
            Positioned(
              left: -MediaQuery.of(context).size.height / 4,
              top: -40,
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.height / 2,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.5)),
              ),
            ),
            Positioned(
              left: -MediaQuery.of(context).size.height / 3,
              top: 0,
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.height / 2,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.5)),
              ),
            ),
            Positioned(
              right: -MediaQuery.of(context).size.height / 8,
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height / 4,
                width: MediaQuery.of(context).size.height / 4,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2)),
              ),
            ),
            Positioned(
              right: -MediaQuery.of(context).size.height / 6,
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height / 4,
                width: MediaQuery.of(context).size.height / 4,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2)),
              ),
            ),
            Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ListView(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    /*  Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/calendar.png"))),
                  ),*/
                    SizedBox(
                      height: 30,
                    ),
                    Center(
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      spreadRadius: 5)
                                ]),
                            child: Image.asset("assets/images/ke.png"))),
                    SizedBox(
                      height: 50,
                    ),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  spreadRadius: 5)
                            ],
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 15,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
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
                                  child: TextFormField(
                                    style: TextStyle(color: Colors.black),
                                    controller: _username,
                                    validator: (value) => value.isEmpty
                                        ? LocalizationsKE.of(context)
                                            .usuarioenblanco
                                        : null,
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                      labelText:
                                          LocalizationsKE.of(context).usuario,
                                      suffixIcon: IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            color: Colors.red,
                                            size: 20.0,
                                          ),
                                          onPressed: () => _username.clear()),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
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
                                  child: TextFormField(
                                    controller: _password,
                                    obscureText: true,
                                    validator: (value) => value.isEmpty
                                        ? LocalizationsKE.of(context)
                                            .passwordenblanco
                                        : null,
                                    style: TextStyle(color: Colors.black),
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                      labelText: LocalizationsKE.of(context)
                                          .contrasena,
                                      suffixIcon: IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            color: Colors.red,
                                            size: 20.0,
                                          ),
                                          onPressed: () => _password.clear()),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  authenticate();
                                },
                                child: Center(
                                  child: Container(
                                    width: 500,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.blue),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                          child: Text(
                                        LocalizationsKE.of(context).entrar,
                                        style: TextStyle(color: Colors.white),
                                      )),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Center(
                                  child: GestureDetector(
                                onTap: () =>
                                    passwordRecovery(context, "title", "text"),
                                child: Text(
                                  LocalizationsKE.of(context).recuperarpassword,
                                  style: TextStyle(color: Colors.blue),
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUp()));
                        },
                        child: Center(
                          child:
                              Text(LocalizationsKE.of(context).registrarcuenta,
                                  style: TextStyle(
                                    color: Colors.white,
                                  )),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                        onTap: () {
                          setAPIAddress(context);
                        },
                        child: Center(
                          child: Text("Cambiar API",
                              style: TextStyle(
                                color: Colors.white,
                              )),
                        )),
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
    );
  }
}
