import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tcm/core/blocs/extension.dart';
import 'package:tcm/core/blocs/handle_error.dart';
import 'package:tcm/core/blocs/product/product_state.dart';
import 'package:tcm/core/repos/product_repo.dart';
import 'package:tcm/models/product.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepo _repo;

  ProductCubit(ProductRepo repo)
      : _repo = repo,
        super(ProductInitialState());

  Future getProductList() async {
    try {
      SmartDialog.showLoading();
      Response res = await _repo.getProductList();
      List<Product> products =
          (res.data as List).map((e) => Product.fromJson(e)).toList();
      maybeEmit(ProductListSuccessState(products));
    } catch (e, s) {
      handleError(e, stackTrace: s);
    } finally {
      SmartDialog.dismiss();
    }
  }
}
