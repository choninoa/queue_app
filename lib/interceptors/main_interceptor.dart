import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ke/interceptors/connectivity_problems.dart';

class MainInterceptor extends Interceptor {
  final HandlingConnectivityProblems requestRetrier;
  //final HandlingTokenProblems handlingTokens;
  //final NotCredits credits;

  MainInterceptor({this.requestRetrier
      //, this.handlingTokens, this.credits
      });

  @override
  Future onError(DioError err) async {
    if (_shouldRetry(err)) {
      try {
        return requestRetrier.retryWhenAvailable(err.request);
      } catch (e) {
        return e;
      }
    }
    /*else {
      if (err.response?.statusCode == 401) {
        try {
          try {
            return handlingTokens.getNewTokens(err.request);
          } catch (e) {
            return null;
          }
        } catch (e) {
          return e;
        }
      }
    }
    if (err.response?.statusCode == 400) {
      var aa = credits.retrieveMessage(err.request);
      return aa;
    }*/

    return err;
  }

  bool _shouldRetry(DioError err) {
    return err.type == DioErrorType.DEFAULT &&
        err.error != null &&
        err.error is SocketException;
  }
}
