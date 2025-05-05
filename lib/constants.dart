import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ConstantsKeyCache {
  ConstantsKeyCache._();
  static String keyLanguageCode = 'LANGUAGE_CODE';
  static String keyTokenType = "TOKEN_TYPE";
  static String keyAccessToken = "ACCESS_TOKEN";
  static String keyRefreshToken = "REFRESH_TOKEN";
  static String keyFCMToken = "FCM_TOKEN";
  static String keyIsFirst = "IS_FIRST";
  static String keyUser = "USER";
  static String keyThemeMode = "THEME_MODE";
  static String keyIsDoctor = "IS_DOCTOR";
  static const String keyOrderDraft = 'ORDER_DRAFT';
  static const String keyOrderScaleFactor = 'ORDER_SCALE_FACTOR';
}

class ConstantsHttp {
  ConstantsHttp._();

  static const String baseUrl =
      kDebugMode ? 'http://127.0.0.1:5000' : 'https://tcm.and2long.tech';
  static const String orders = '/orders';
  static const String pendingOrders = '/orders/pending';
  static const String contacts = '/contacts';
  static const String products = '/products';
  static const String upload = '/upload';
  static const String checkNewVersion = '/update/check-new-version';
}

const appBarHeight = kToolbarHeight;
const tileHeight = 55.0;
