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

  Future<List<Product>?> getProductList() async {
    try {
      SmartDialog.showLoading();
      Response res = await _repo.getProductList();
      List<Product> products =
          (res.data as List).map((e) => Product.fromJson(e)).toList();
      maybeEmit(ProductListSuccessState(products));
      return products;
    } catch (e, s) {
      handleError(e, stackTrace: s);
      return null;
    } finally {
      SmartDialog.dismiss();
    }
  }

  Future createProduct(String name) async {
    try {
      SmartDialog.showLoading();
      Response res = await _repo.createProduct(name);
      Product product = Product.fromJson(res.data);
      maybeEmit(ProductCreateSuccessState(product));
    } catch (e, s) {
      handleError(e, stackTrace: s);
    } finally {
      SmartDialog.dismiss();
    }
  }

  Future deleteProduct(int id) async {
    try {
      SmartDialog.showLoading();
      await _repo.deleteProduct(id);
      maybeEmit(ProductDeleteSuccessState(id));
      await getProductList(); // 删除成功后刷新列表
    } catch (e, s) {
      handleError(e, stackTrace: s);
    } finally {
      SmartDialog.dismiss();
    }
  }
}
