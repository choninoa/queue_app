import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';

class HandlingConnectivityProblems {
  final Dio dio;
  final Connectivity connectivity;

  HandlingConnectivityProblems({
    this.dio,
    this.connectivity,
  });

  Future<Response> retryWhenAvailable(RequestOptions requestOptions) async {
    StreamSubscription streamSubscription;
    final responseCompleter = Completer<Response>();

    streamSubscription = connectivity.onConnectivityChanged.listen(
      (connectivityResult) async {
        if (connectivityResult != ConnectivityResult.none) {
          streamSubscription.cancel();
          responseCompleter.complete(
            dio.request(
              requestOptions.path,
              cancelToken: requestOptions.cancelToken,
              data: requestOptions.data,
              onReceiveProgress: requestOptions.onReceiveProgress,
              onSendProgress: requestOptions.onSendProgress,
              queryParameters: requestOptions.queryParameters,
              options: requestOptions,
            ),
          );
        }
      },
    );

    return responseCompleter.future;
  }
}
