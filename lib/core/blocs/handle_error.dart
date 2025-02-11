import 'package:flutter_ytlog/log.dart';
import 'package:tcm/utils/toast_util.dart';

const String _tag = 'HandleError';
void handleError(Object e, {StackTrace? stackTrace}) {
  Log.e(_tag, e);
  Log.e(_tag, stackTrace);
  ToastUtil.show(e.toString());
}
