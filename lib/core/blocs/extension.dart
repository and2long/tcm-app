import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

extension BlocBaseExtension<T> on BlocBase<T> {
  void maybeEmit(T state) {
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    if (!isClosed) emit(state);
  }
}

extension DateTimeExtensions on DateTime {
  String formatStyle1() {
    return DateFormat('yyyy-MM-dd HH:mm').format(this);
  }

  String formatStyle2() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(this);
  }

  String formatStyle3() {
    return DateFormat('yyyy.MM.dd').format(this);
  }
}
