class GenderUtils {
  // 中文到英文的映射
  static const Map<String, String> _chineseToEnglish = {
    '男': 'male',
    '女': 'female',
  };

  // 英文到中文的映射
  static const Map<String, String> _englishToChinese = {
    'male': '男',
    'female': '女',
  };

  /// 将中文性别转换为英文（用于API请求）
  static String? chineseToEnglish(String? chineseGender) {
    if (chineseGender == null || chineseGender.isEmpty) return null;
    return _chineseToEnglish[chineseGender];
  }

  /// 将英文性别转换为中文（用于界面显示）
  static String? englishToChinese(String? englishGender) {
    if (englishGender == null || englishGender.isEmpty) return null;
    return _englishToChinese[englishGender];
  }

  /// 获取中文性别选项列表
  static List<String> getChineseOptions() {
    return ['男', '女'];
  }

  /// 获取英文性别选项列表
  static List<String> getEnglishOptions() {
    return ['male', 'female'];
  }
}
