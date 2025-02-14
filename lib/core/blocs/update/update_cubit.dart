import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tcm/core/blocs/extension.dart';
import 'package:tcm/core/blocs/handle_error.dart';
import 'package:tcm/core/blocs/update/update_state.dart';
import 'package:tcm/core/repos/update_repo.dart';

class UpdateCubit extends Cubit<UpdateState> {
  final UpdateRepo _repo;

  UpdateCubit(UpdateRepo repo)
      : _repo = repo,
        super(UpdateInitialState());

  Future checkUpdate() async {
    try {
      SmartDialog.showLoading();
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = int.parse(packageInfo.buildNumber);

      Response res = await _repo.checkNewVersion();
      final latestVersion = res.data['build_number'] as int;

      if (latestVersion > currentVersion) {
        maybeEmit(UpdateAvailableState(
          buildNumber: res.data['build_number'] ?? 0,
          buildVersion: res.data['build_version'] ?? '',
          downloadUrl: res.data['download_url'] ?? '',
          description: res.data['description'] ?? '',
        ));
      } else {
        maybeEmit(NoUpdateAvailableState());
        SmartDialog.showToast('已经是最新版本');
      }
    } catch (e, s) {
      handleError(e, stackTrace: s);
    } finally {
      SmartDialog.dismiss();
    }
  }
}
