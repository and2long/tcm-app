import 'package:dio/dio.dart';
import 'package:tcm/constants.dart';
import 'package:tcm/core/network/http.dart';

class UploadRepo {
  Future<Response> uploadImage(String path,
      {String? type, String? username}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(path),
      'type': type,
      'username': username,
    });
    return XHttp.instance.post(ConstantsHttp.upload, data: formData);
  }
}
