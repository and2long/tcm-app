import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tcm/constants.dart';
import 'package:tcm/core/network/http.dart';

class OrderRepo {
  Future<Response> getOrderList() async {
    return XHttp.instance.get(ConstantsHttp.orders);
  }

  Future<Response> createOrder({
    required int contactId,
    required List<Map<String, int>> items,
    List<XFile>? images,
  }) async {
    final formData = FormData.fromMap({
      'contact_id': contactId,
      'order_lines': items,
      if (images != null)
        'images': await Future.wait(
          images.map(
            (image) async => await MultipartFile.fromFile(image.path),
          ),
        ),
    });

    return XHttp.instance.post(
      ConstantsHttp.orders,
      data: formData,
    );
  }
}
