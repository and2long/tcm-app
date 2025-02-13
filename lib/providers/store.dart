import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:tcm/core/blocs/contact/contact_cubit.dart';
import 'package:tcm/core/blocs/order/order_cubit.dart';
import 'package:tcm/core/blocs/product/product_cubit.dart';
import 'package:tcm/core/repos/contact_repo.dart';
import 'package:tcm/core/repos/order_repo.dart';
import 'package:tcm/core/repos/product_repo.dart';
import 'package:tcm/core/repos/upload_repo.dart';
import 'package:tcm/providers/app_provider.dart';
import 'package:tcm/utils/sp_util.dart';

/// 全局状态管理
class Store {
  Store._internal();

  // 初始化
  static init(Widget child) {
    return MultiProvider(
      providers: [
        // 国际化
        ChangeNotifierProvider.value(
            value: LocaleStore(SPUtil.getLanguageCode())),
        ChangeNotifierProvider(
            create: (_) => AppProvider(themeMode: SPUtil.getThemeMode())),
        BlocProvider(create: (_) => OrderCubit(OrderRepo())),
        BlocProvider(create: (_) => ContactCubit(ContactRepo())),
        BlocProvider(create: (_) => ProductCubit(ProductRepo())),
        Provider(create: (_) => UploadRepo()),
      ],
      child: child,
    );
  }
}

/// 语言
class LocaleStore with ChangeNotifier {
  String _languageCode;

  LocaleStore(this._languageCode);

  String get languageCode => _languageCode;

  void setLanguageCode(String languageCode) {
    _languageCode = languageCode;
    SPUtil.setLanguageCode(languageCode);
    notifyListeners();
  }
}
