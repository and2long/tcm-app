abstract class UpdateState {}

class UpdateInitialState extends UpdateState {}

class UpdateAvailableState extends UpdateState {
  final int buildNumber;
  final String buildVersion;
  final String downloadUrl;
  final String description;

  UpdateAvailableState({
    required this.buildNumber,
    required this.buildVersion,
    required this.downloadUrl,
    required this.description,
  });
}

class NoUpdateAvailableState extends UpdateState {}
