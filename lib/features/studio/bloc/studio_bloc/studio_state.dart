part of 'studio_bloc.dart';

abstract class StudioState extends Equatable {
  final List<Studio> studios;
  final Studio currentEditingStudio;
  final String? error;

  const StudioState({
    required this.studios,
    required this.currentEditingStudio,
    this.error,
  });

  bool get isLoading => this is StudioLoading;
  bool get isEditing => this is StudioEditing;
  bool get hasError => error != null;

  @override
  List<Object?> get props => [studios, currentEditingStudio, error];
}

class StudioInitial extends StudioState {
  StudioInitial() : super(
    studios: [],
    currentEditingStudio: Studio.empty(),
  );
}

class StudioLoading extends StudioState {
  const StudioLoading({
    required List<Studio> studios,
    required Studio currentEditingStudio,
  }) : super(
    studios: studios,
    currentEditingStudio: currentEditingStudio,
  );
}

class StudioOperationSuccess extends StudioState {
  const StudioOperationSuccess({
    required List<Studio> studios,
    required Studio currentEditingStudio,
  }) : super(
    studios: studios,
    currentEditingStudio: currentEditingStudio,
  );
}

class StudioOperationFailure extends StudioState {
  const StudioOperationFailure({
    required List<Studio> studios,
    required Studio currentEditingStudio,
    required String error,
  }) : super(
    studios: studios,
    currentEditingStudio: currentEditingStudio,
    error: error,
  );
}

class StudioEditing extends StudioState {
  const StudioEditing({
    required List<Studio> studios,
    required Studio currentEditingStudio,
  }) : super(
    studios: studios,
    currentEditingStudio: currentEditingStudio,
  );
}