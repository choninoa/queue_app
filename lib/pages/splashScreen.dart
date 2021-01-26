import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ke/wrapper.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 1)).then((value) => Navigator.push(
        context, MaterialPageRoute(builder: (context) => Wrapper())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(
          tag: "calendario",
                  child: Container(
            padding: EdgeInsets.all(5),
            height: 152,
            width: 152,
            decoration: BoxDecoration(
                color: Color.fromRGBO(131, 59, 224, 1),
                borderRadius: BorderRadius.circular(45)),
            child: Center(
              child: AutoSizeText(
                "KE",
                style: TextStyle(
                    fontSize: 100, color: Colors.white, fontFamily: "Fonarto"),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
