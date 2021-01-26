import 'package:ke/utils/apiCalls.dart';

class ApiServicesProvider {
  ApiCalls _apiCalls;

  ApiCalls get apiCalls => _apiCalls;
  ApiServicesProvider() {
    _apiCalls = ApiCalls();
  }
}
