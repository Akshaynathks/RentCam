import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'version_event.dart';
part 'version_state.dart';

class VersionBloc extends Bloc<VersionEvent, VersionState> {
  VersionBloc() : super(VersionInitial()) {
    on<LoadVersionEvent>((event, emit) async {
      emit(VersionLoading());
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        final version = 'v${packageInfo.version}';
        
        emit(VersionLoaded(version: version));
        
        await Future.delayed(const Duration(seconds: 2));
        emit(VersionReady(version: version, canNavigate: true));
      } catch (e) {
        emit(VersionError(error: 'Failed to load version info'));
      }
    });
  }
}