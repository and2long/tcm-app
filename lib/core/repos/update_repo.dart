import 'package:dio/dio.dart';
import 'package:tcm/constants.dart';
import 'package:tcm/core/network/http.dart';

class UpdateRepo {
  Future<Response> checkNewVersion() async {
    return XHttp.instance.get(ConstantsHttp.checkNewVersion);
  }
}
