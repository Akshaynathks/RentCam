part of 'version_bloc.dart';

@immutable
sealed class VersionState {}

class VersionInitial extends VersionState {}

class VersionLoading extends VersionState {}

class VersionLoaded extends VersionState {
  final String version;
  VersionLoaded({required this.version});
}

class VersionReady extends VersionState {
  final String version;
  final bool canNavigate;
  VersionReady({required this.version, required this.canNavigate});
}

class VersionError extends VersionState {
  final String error;
  VersionError({required this.error});
}