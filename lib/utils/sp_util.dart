import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcm/constants.dart';
import 'package:tcm/i18n/i18n.dart';

class SPUtil {
  SPUtil._internal();

  static late SharedPreferences _spf;

  static Future<SharedPreferences?> init() async {
    _spf = await SharedPreferences.getInstance();
    return _spf;
  }

  /// 首次引导
  static Future<bool> setFirst(bool first) {
    return _spf.setBool(ConstantsKeyCache.keyIsFirst, first);
  }

  static bool isFirst() {
    return _spf.getBool(ConstantsKeyCache.keyIsFirst) ?? true;
  }

  /// 语言
  static Future<bool> setLanguageCode(String languageCode) {
    return _spf.setString(ConstantsKeyCache.keyLanguageCode, languageCode);
  }

  static String getLanguageCode() {
    return _spf.getString(ConstantsKeyCache.keyLanguageCode) ??
        S.supportedLocales.first.languageCode;
  }

  static Future<bool> saveAccessToken(String? token) {
    return _spf.setString(ConstantsKeyCache.keyAccessToken, token ?? '');
  }

  static String? getAccessToken() {
    return _spf.getString(ConstantsKeyCache.keyAccessToken);
  }

  static Future<bool> saveTokenType(String? value) {
    return _spf.setString(ConstantsKeyCache.keyTokenType, value ?? '');
  }

  static String getTokenType() {
    return _spf.getString(ConstantsKeyCache.keyTokenType) ?? '';
  }

  static Future<bool> saveRefreshToken(String? token) {
    return _spf.setString(ConstantsKeyCache.keyRefreshToken, token ?? '');
  }

  static String? getRefreshToken() {
    return _spf.getString(ConstantsKeyCache.keyRefreshToken);
  }

  static Future<bool> saveThemeMode(ThemeMode mode) {
    return _spf.setString(ConstantsKeyCache.keyThemeMode, mode.name);
  }

  static ThemeMode getThemeMode() {
    final String? mode = _spf.getString(ConstantsKeyCache.keyThemeMode);
    return ThemeMode.values.firstWhere(
      (e) => e.name == mode,
      orElse: () => ThemeMode.system,
    );
  }

  static bool getIsDoctor() {
    return _spf.getBool(ConstantsKeyCache.keyIsDoctor) ?? true;
  }

  static Future<bool> saveIsDoctor(bool isDoctor) async {
    return await _spf.setBool(ConstantsKeyCache.keyIsDoctor, isDoctor);
  }

  static Future<bool> saveOrderListLayout(bool isSingleColumn) {
    return _spf.setBool(
        ConstantsKeyCache.keyOrderListSingleColumn, isSingleColumn);
  }

  static bool getOrderListLayout() {
    return _spf.getBool(ConstantsKeyCache.keyOrderListSingleColumn) ?? true;
  }
}
