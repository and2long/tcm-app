import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_ytlog/log.dart';
import 'package:provider/provider.dart';
import 'package:tcm/core/network/http.dart';
import 'package:tcm/i18n/i18n.dart';
import 'package:tcm/pages/home.dart';
import 'package:tcm/pages/operate_page.dart';
import 'package:tcm/providers/app_provider.dart';
import 'package:tcm/providers/store.dart';
import 'package:tcm/theme.dart';
import 'package:tcm/utils/sp_util.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SPUtil.init().then((value) {
    XHttp.init();
    runApp(Store.init(const MyApp()));
  });
  // 安卓透明状态栏
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));
  }
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        // 程序的字体大小不受系统字体大小影响
        textScaler: TextScaler.noScaling,
      ),
      child: Consumer<LocaleStore>(
          builder: (BuildContext context, LocaleStore value, Widget? child) {
        return Consumer<AppProvider>(
          builder: (context, provider, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              navigatorKey: MyApp.navigatorKey,
              onGenerateTitle: (context) => S.appName,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: provider.themeMode,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                // 项目本地化资源代理
                S.delegate,
              ],
              // 支持的语言
              supportedLocales: S.supportedLocales,
              locale: Locale(value.languageCode),
              home:
                  SPUtil.getIsDoctor() ? const HomePage() : const OperatePage(),
              navigatorObservers: [MyRouteObserver()],
              // builder: (context, child) => GestureDetector(
              //   onTap: () => CommonUtil.hideKeyboard(context),
              // ),
              builder: FlutterSmartDialog.init(
                loadingBuilder: (String msg) => CustomLoadingWidget(msg: msg),
              ),
            );
          },
        );
      }),
    );
  }
}

class CustomLoadingWidget extends StatelessWidget {
  final String msg;
  const CustomLoadingWidget({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const SpinKitFadingCircle(
        color: Colors.white,
        size: 40.0,
      ),
    );
  }
}

class MyRouteObserver<R extends Route<dynamic>> extends RouteObserver<R> {
  final String _tag = 'MyRouteObserver';
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    Log.i(_tag, '⤴️ push to route: ${route.settings.name}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    String curPageName = newRoute?.settings.name ?? '';
    Log.i(_tag, '🔂 replace to route: $curPageName');
  }

  @override
  void didPop(Route route, Route? previousRoute) async {
    super.didPop(route, previousRoute);
    String curPageName = previousRoute?.settings.name ?? '';
    Log.i(_tag, '⤵️ pop to route: $curPageName');
  }
}
