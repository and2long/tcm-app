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
}

class ConstantsHttp {
  ConstantsHttp._();

  static const String baseUrl = 'http://127.0.0.1:5000';
  static const String orders = '/orders';
  static const String pendingOrders = '/orders/pedding';
  static const String contacts = '/contacts';
  static const String products = '/products';
  static const String upload = '/upload';
}

const appBarHeight = kToolbarHeight;
const tileHeight = 55.0;
