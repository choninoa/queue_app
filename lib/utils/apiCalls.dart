import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:ke/interceptors/connectivity_problems.dart';
import 'package:ke/interceptors/main_interceptor.dart';
import 'package:ke/persistence/models/storeModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

Dio dios;
//Dio dios = Dio(BaseOptions(baseUrl: "https://b62ccecee01b.ngrok.io/v1"));
//Dio dios = Dio(BaseOptions(baseUrl: "https://api.easycubaservices.com/v1"));

class ApiCalls {
  SharedPreferences prefs;

  ApiCalls() {
    init();
  }

  init() async {
    prefs = await SharedPreferences.getInstance();
    String apiaddress = prefs.getString('apiaddress');
    print(apiaddress);
    dios = Dio(BaseOptions(
        baseUrl: apiaddress != null ? apiaddress : "http://kevirtual.com:3000"));
    // String tokenrefresh = prefs.getString("tokenrefresh");
    // String tokenaccess = prefs.getString("tokenaccess");
    /*(dios.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate  = (client) {
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
};*/
    dios.interceptors.add(
      MainInterceptor(
        /* handlingTokens: HandlingTokenProblems(
        access: tokenaccess,
            refresh: tokenrefresh,
            dio: dios,
           ),*/
        requestRetrier: HandlingConnectivityProblems(
          dio: dios,
          connectivity: Connectivity(),
        ),
        //credits: NotCredits(dio: dios)
      ),
    );
  }

/*   Authentication   */

  logIn(String usuario, String pass) async {
    try {
      var res = await dios.post("/security/login",
          data: {"password": pass, "username": usuario});
      if (res.statusCode == 201) {
        return res;
      } else {
        print(res.data.toString());
      }
    } catch (e) {
      return null;
    }
  }

  Future registerUser(
      {String email,
      String username,
      String name,
      String address,
      String password,
      String phone}) async {
    try {
      var res = await dios.post(
        "/security/user/create",
        data: {
          "email": email,
          "username": username,
          "fullname": name,
          "address": address,
          "password": password,
          //"confirm_password": password,
          "phone": phone,
        },
        /*options: Options(headers: {
            HttpHeaders.authorizationHeader: "Bearer " + tokenaccess
          })*/
      );
      if (res.statusCode == 200) {
        print(res.data);
        return res.data;
      } else {
        return res.statusCode.toString();
      }
    } catch (e) {
      return null;
    }
  }

  confirmAccount(String usuario, String code) async {
    try {
      var res = await dios.post("/users/confirm-account",
          data: {"confirmation_code": code, "email": usuario});
      if (res.statusCode == 200) {
        print(res.data);
        return res;
      } else if (res.statusCode == 401) {
        return null;
      } else {
        print(res.statusCode.toString());
        print(res.data.toString());
        return res;
      }
    } catch (e) {
      return null;
    }
  }

  passwordChangeRequest(String email) async {
    try {
      var res = await dios
          .post("/users/password-change-request", data: {"email": email});
      print(res.data);
      return res;
    } catch (e) {
      return null;
    }
  }

/*   GET   */

  Future getStoresByCity() async {
    try {
      var res = await dios.get("/store",
          options: Options(
              headers: {HttpHeaders.authorizationHeader: accessToken()}));
      if (res.statusCode == 200) {
        print(res.data);
        return res.data;
      } else {
        return res.statusCode.toString();
      }
    } catch (e) {
      return null;
    }
  }

  Future getStoreById(String id) async {
    try {
      var res = await dios.get("/store/$id",
          options: Options(
              headers: {HttpHeaders.authorizationHeader: accessToken()}));
      if (res.statusCode == 200) {
        print(res.data);
        return res.data;
      } else {
        return res.statusCode.toString();
      }
    } catch (e) {
      return null;
    }
  }

  Future getReservations({Map<String, dynamic> query}) async {
    try {
      var res = await dios.get("/reservation",
          queryParameters: query,
          options: Options(
              headers: {HttpHeaders.authorizationHeader: accessToken()}));
      if (res.statusCode == 200) {
        print(res.data);
        return res.data;
      } else {
        return res.statusCode.toString();
      }
    } catch (e) {
      return null;
    }
  }

/*   POST   */

  Future createReservation(String idStore, String idUser, String nameStore,
      String date, int cantP) async {
    try {
      var res = await dios.post("/reservation/create",
          data: {
            "date": date,
            "idUser": idUser,
            "idStore": idStore,
            "storeName": nameStore,
            "cant": cantP,
          },
          options: Options(headers: {
            HttpHeaders.authorizationHeader: accessToken(),
          }));
      if (res.statusCode == 201) {
        print(res.data);
        return res.data;
      } else {
        return res.statusCode.toString();
      }
    } catch (e) {
      return null;
    }
  }

  Future deleteStore(String idStore) async {
    try {
      var res = await dios.delete("/store/delete",
          data: {"idStore": idStore},
          options: Options(headers: {
            HttpHeaders.authorizationHeader: accessToken(),
          }));
      if (res.statusCode == 201) {
        print(res.data);
        return res.data;
      } else {
        return res.statusCode.toString();
      }
    } catch (e) {
      return null;
    }
  }

  Future createStore(StoreModel store) async {
    try {
      var res = await dios.post("/store/create",
          data: {
            "gps": {"lat": store.latitude, "lon": store.longitude},
            "name": store.name,
            "bunchClients": store.bunchClients,
            "estimateMinutes": store.estimateMinutes,
            "address": store.address,
            "openAt": store.openAt,
            "closedAt": store.closedAt
          },
          options: Options(headers: {
            HttpHeaders.authorizationHeader: accessToken(),
          }));
      if (res.statusCode == 201) {
        print(res.data);
        return res.data;
      } else {
        return res.statusCode.toString();
      }
    } catch (e) {
      return null;
    }
  }

  Future checkReservation(
      {String idReservation, String idStore, String idUser}) async {
    try {
      var res = await dios.post("/store/passdoor",
          data: {
            "idUser": idUser,
            "idStore": idStore,
            "idReservation": idReservation,
          },
          options: Options(headers: {
            HttpHeaders.authorizationHeader: accessToken(),
          }));
      if (res.statusCode == 200) {
        print(res.data);
        return res.data;
      } else {
        return res.statusCode.toString();
      }
    } catch (e) {
      return null;
    }
  }







  Future setUserImage(String image, int id) async {
    try {
      var res = await dios.patch("/users",
          data: {
            "image": image,
            "id": id,
          },
          options: Options(
              headers: {HttpHeaders.authorizationHeader: accessToken()}));
      if (res.statusCode == 200) {
        print(res.data);
        return res.data;
      } else {
        return res.statusCode.toString();
      }
    } catch (e) {
      return null;
    }
  }



  Future uploadUserPicture(File file, int idUser) async {
    try {
      FormData formData = new FormData.fromMap({
        "idUser": idUser,
        "file": await MultipartFile.fromFile(file.path, filename: "user$idUser")
      });
      var res = await dios.post("/storage/user/$idUser",
          data: formData,
          options: Options(headers: {
            HttpHeaders.authorizationHeader: accessToken(),
          }));
      if (res.statusCode == 200) {
        print(res.data);
        return res.data;
      } else {
        return res.statusCode.toString();
      }
    } catch (e) {
      return null;
    }
  }

  logOut(String token) async {
    String tokenrefresh = prefs.getString("tokenrefresh");
    var res = await dios.post("/user/logout/",
        data: {
          "refresh": tokenrefresh,
        },
        options: Options(headers: {
          HttpHeaders.authorizationHeader: accessToken(),
        }));
    if (res.statusCode == 200) {
      return res.data;
    }
    return null;
  }

  String accessToken() {
    return "Bearer " + prefs.getString("token");
  }
}
