import 'package:dio/dio.dart';
import 'package:tcm/constants.dart';
import 'package:tcm/core/network/http.dart';

class UploadRepo {
  Future<Response> uploadImage(String path) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(path),
    });
    return XHttp.instance.post(ConstantsHttp.upload, data: formData);
  }
}
