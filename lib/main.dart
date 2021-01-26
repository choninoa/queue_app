import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ke/providers/authServices.dart';
import 'package:ke/providers/currentPositionProvider.dart';
import 'package:ke/providers/currentUser.dart';
import 'package:ke/utils/localizationsKE.dart';
import 'package:ke/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AuthUtils/logIn.dart';
import 'providers/apiServicesProvider.dart';
import 'package:ke/pages/MapPage.dart';

var isLoggedIn = false;
var isFirstTime = true;
var orders;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  isFirstTime = prefs.getBool('isFirstTime') ?? true;
  String userobject = prefs?.getString("userobject");
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthServices>(
        create: (_) => AuthServices(
            loggedin: isLoggedIn,
            usermap: userobject,
            isFirstTime: isFirstTime),
      ),
      Provider<ApiServicesProvider>(
        create: (_) => ApiServicesProvider(),
      ),
     
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CurrentUser>(
          create: (_) => CurrentUser(),
        ),
        ChangeNotifierProvider<CurrentPositionProvider>(
          create: (_) => CurrentPositionProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Virtual KE',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          LocalizationsKEDelegate()
        ],
        supportedLocales: [
          const Locale('en', ''),
          const Locale('es', ''),
          const Locale('fr', ''),
        ],
        home: FutureBuilder(
          future: Provider.of<AuthServices>(context).getUser(),
          builder: (context, AsyncSnapshot snapshot) {
            return snapshot.hasData ? Wrapper() : LogIn();
          },
        ),
      ),
    );
  }
}
