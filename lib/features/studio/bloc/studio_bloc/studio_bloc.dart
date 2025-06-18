import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:rent_cam/features/studio/model/studio_model.dart';
import 'package:rent_cam/features/studio/service/studio_service.dart';

part 'studio_event.dart';
part 'studio_state.dart';

class StudioBloc extends Bloc<StudioEvent, StudioState> {
  final StudioFirestoreService _studioService;

  StudioBloc(this._studioService) : super(StudioInitial()) {
    on<LoadStudios>(_onLoadStudios);
    on<AddStudio>(_onAddStudio);
    on<UpdateStudio>(_onUpdateStudio);
    on<DeleteStudio>(_onDeleteStudio);
    on<StartEditingStudio>(_onStartEditingStudio);
    on<CancelEditingStudio>(_onCancelEditingStudio);
    on<AddTrendingImage>(_onAddTrendingImage);
    on<RemoveTrendingImage>(_onRemoveTrendingImage);
    on<AddService>(_onAddService);
    on<RemoveService>(_onRemoveService);
    on<AddPackage>(_onAddPackage);
    on<UpdateServiceName>(_onUpdateServiceName);
    on<UpdateServiceImage>(_onUpdateServiceImage);
    on<UpdatePackageName>(_onUpdatePackageName);
    on<UpdatePackagePhotoCount>(_onUpdatePackagePhotoCount);
    on<UpdatePackageWorkingHours>(_onUpdatePackageWorkingHours);
    on<UpdatePackagePhotographers>(_onUpdatePackagePhotographers);
    on<UpdatePackageRate>(_onUpdatePackageRate);
    on<RemovePackage>(_onRemovePackage);
    add(LoadStudios());
  }

  Future<void> _onLoadStudios(
      LoadStudios event, Emitter<StudioState> emit) async {
    emit(StudioLoading(
      studios: state.studios,
      currentEditingStudio: state.currentEditingStudio,
    ));

    try {
      final studiosStream = _studioService.getStudios();
      final List<Studio> studios = await studiosStream.first;

      emit(StudioOperationSuccess(
        studios: studios,
        currentEditingStudio: state.currentEditingStudio,
      ));
    } catch (e) {
      emit(StudioOperationFailure(
        studios: state.studios,
        currentEditingStudio: state.currentEditingStudio,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onAddStudio(AddStudio event, Emitter<StudioState> emit) async {
    emit(StudioLoading(
      studios: state.studios,
      currentEditingStudio: state.currentEditingStudio,
    ));

    final result = await _studioService.addStudio(event.studio);

    if (result == 'limit_reached') {
      emit(StudioOperationSuccess(
        studios: state.studios,
        currentEditingStudio: Studio.empty(),
      ));

      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          SnackBar(
            content: Text(
              'You can only have one studio. Please edit your existing studio instead.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(event.context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
      return;
    } else if (result == 'error') {
      emit(StudioOperationFailure(
        studios: state.studios,
        currentEditingStudio: state.currentEditingStudio,
        error: 'Failed to add studio',
      ));
      return;
    }

    try {
      final studios = await _studioService.getStudios().first;
      emit(StudioOperationSuccess(
        studios: studios,
        currentEditingStudio: Studio.empty(),
      ));
      Navigator.of(event.context).pop();
    } catch (e) {
      emit(StudioOperationFailure(
        studios: state.studios,
        currentEditingStudio: state.currentEditingStudio,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateStudio(
      UpdateStudio event, Emitter<StudioState> emit) async {
    emit(StudioLoading(
      studios: state.studios,
      currentEditingStudio: state.currentEditingStudio,
    ));

    try {
      // Update the studio in Firebase
      await _studioService.updateStudio(event.studio);

      // Fetch the updated studios list
      final studios = await _studioService.getStudios().first;

      // Find the updated studio in the list
      final updatedStudio = studios.firstWhere((s) => s.id == event.studio.id);

      // Emit success state with the updated studio
      emit(StudioOperationSuccess(
        studios: studios,
        currentEditingStudio: updatedStudio,
      ));

      // Show success message in the UI
      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(
            content: Text('Studio updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // If there's an error, emit failure state
      emit(StudioOperationFailure(
        studios: state.studios,
        currentEditingStudio: state.currentEditingStudio,
        error: e.toString(),
      ));

      // Show error message in the UI
      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          SnackBar(
            content: Text('Error updating studio: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _onDeleteStudio(
      DeleteStudio event, Emitter<StudioState> emit) async {
    if (event.studioId.isEmpty) {
      emit(StudioOperationFailure(
        studios: state.studios,
        currentEditingStudio: state.currentEditingStudio,
        error: 'Invalid studio ID',
      ));
      return;
    }

    emit(StudioLoading(
      studios: state.studios,
      currentEditingStudio: state.currentEditingStudio,
    ));

    try {
      // First, remove the studio from the local state
      final updatedStudios = List<Studio>.from(state.studios)
        ..removeWhere((s) => s.id == event.studioId);

      emit(StudioOperationSuccess(
        studios: updatedStudios,
        currentEditingStudio: state.currentEditingStudio,
      ));

      // Then delete from Firebase
      await _studioService.deleteStudio(event.studioId);

      // Refresh the studios list to ensure consistency
      final studios = await _studioService.getStudios().first;
      emit(StudioOperationSuccess(
        studios: studios,
        currentEditingStudio: Studio.empty(),
      ));

      if (event.context.mounted) {
        Navigator.of(event.context).pop(); // Close the detail page
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(
            content: Text('Studio deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // If there's an error, revert to the previous state
      emit(StudioOperationFailure(
        studios: state.studios,
        currentEditingStudio: state.currentEditingStudio,
        error: e.toString(),
      ));

      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          SnackBar(
            content: Text('Error deleting studio: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _onStartEditingStudio(
      StartEditingStudio event, Emitter<StudioState> emit) {
    emit(StudioEditing(
      studios: state.studios,
      currentEditingStudio: event.studio ?? Studio.empty(),
    ));
  }

  void _onCancelEditingStudio(
      CancelEditingStudio event, Emitter<StudioState> emit) {
    emit(StudioOperationSuccess(
      studios: state.studios,
      currentEditingStudio: Studio.empty(),
    ));
  }

  void _onAddTrendingImage(AddTrendingImage event, Emitter<StudioState> emit) {
    emit(StudioEditing(
      studios: state.studios,
      currentEditingStudio: state.currentEditingStudio.copyWith(
        trendingImages: [
          ...state.currentEditingStudio.trendingImages,
          event.imageUrl
        ],
      ),
    ));
  }

  void _onRemoveTrendingImage(
      RemoveTrendingImage event, Emitter<StudioState> emit) {
    emit(StudioEditing(
      studios: state.studios,
      currentEditingStudio: state.currentEditingStudio.copyWith(
        trendingImages: state.currentEditingStudio.trendingImages
            .where((image) => image != event.imageUrl)
            .toList(),
      ),
    ));
  }

  void _onAddService(AddService event, Emitter<StudioState> emit) {
    emit(StudioEditing(
      studios: state.studios,
      currentEditingStudio: state.currentEditingStudio.copyWith(
        services: [
          ...state.currentEditingStudio.services,
          StudioService.empty(),
        ],
      ),
    ));
  }

  void _onRemoveService(RemoveService event, Emitter<StudioState> emit) {
    final updatedServices =
        List<StudioService>.from(state.currentEditingStudio.services);
    updatedServices.removeAt(event.serviceIndex);

    emit(StudioEditing(
      studios: state.studios,
      currentEditingStudio: state.currentEditingStudio.copyWith(
        services: updatedServices,
      ),
    ));
  }

  void _onAddPackage(AddPackage event, Emitter<StudioState> emit) {
    final updatedServices =
        List<StudioService>.from(state.currentEditingStudio.services);
    updatedServices[event.serviceIndex] =
        updatedServices[event.serviceIndex].copyWith(
      packages: [
        ...updatedServices[event.serviceIndex].packages,
        ServicePackage.empty(),
      ],
    );

    emit(StudioEditing(
      studios: state.studios,
      currentEditingStudio: state.currentEditingStudio.copyWith(
        services: updatedServices,
      ),
    ));
  }

  void _onUpdateServiceName(
      UpdateServiceName event, Emitter<StudioState> emit) {
    final updatedServices =
        List<StudioService>.from(state.currentEditingStudio.services);
    updatedServices[event.serviceIndex] =
        updatedServices[event.serviceIndex].copyWith(
      name: event.name,
    );

    emit(StudioEditing(
      studios: state.studios,
      currentEditingStudio: state.currentEditingStudio.copyWith(
        services: updatedServices,
      ),
    ));
  }

  void _onUpdateServiceImage(
      UpdateServiceImage event, Emitter<StudioState> emit) {
    final updatedServices =
        List<StudioService>.from(state.currentEditingStudio.services);
    updatedServices[event.serviceIndex] =
        updatedServices[event.serviceIndex].copyWith(
      image: event.imageUrl,
    );

    emit(StudioEditing(
      studios: state.studios,
      currentEditingStudio: state.currentEditingStudio.copyWith(
        services: updatedServices,
      ),
    ));
  }

  void _onUpdatePackageName(
      UpdatePackageName event, Emitter<StudioState> emit) {
    final updatedServices =
        List<StudioService>.from(state.currentEditingStudio.services);
    final updatedPackages =
        List<ServicePackage>.from(updatedServices[event.serviceIndex].packages);
    updatedPackages[event.packageIndex] =
        updatedPackages[event.packageIndex].copyWith(
      name: event.name,
    );
    updatedServices[event.serviceIndex] =
        updatedServices[event.serviceIndex].copyWith(
      packages: updatedPackages,
    );

    emit(StudioEditing(
      studios: state.studios,
      currentEditingStudio: state.currentEditingStudio.copyWith(
        services: updatedServices,
      ),
    ));
  }

  void _onUpdatePackagePhotoCount(
      UpdatePackagePhotoCount event, Emitter<StudioState> emit) {
    final updatedServices =
        List<StudioService>.from(state.currentEditingStudio.services);
    final updatedPackages =
        List<ServicePackage>.from(updatedServices[event.serviceIndex].packages);
    updatedPackages[event.packageIndex] =
        updatedPackages[event.packageIndex].copyWith(
      photoCount: event.photoCount,
    );
    updatedServices[event.serviceIndex] =
        updatedServices[event.serviceIndex].copyWith(
      packages: updatedPackages,
    );

    emit(StudioEditing(
      studios: state.studios,
      currentEditingStudio: state.currentEditingStudio.copyWith(
        services: updatedServices,
      ),
    ));
  }

  void _onUpdatePackageWorkingHours(
      UpdatePackageWorkingHours event, Emitter<StudioState> emit) {
    final updatedServices =
        List<StudioService>.from(state.currentEditingStudio.services);
    final updatedPackages =
        List<ServicePackage>.from(updatedServices[event.serviceIndex].packages);
    updatedPackages[event.packageIndex] =
        updatedPackages[event.packageIndex].copyWith(
      workingHours: event.workingHours,
    );
    updatedServices[event.serviceIndex] =
        updatedServices[event.serviceIndex].copyWith(
      packages: updatedPackages,
    );

    emit(StudioEditing(
      studios: state.studios,
      currentEditingStudio: state.currentEditingStudio.copyWith(
        services: updatedServices,
      ),
    ));
  }

  void _onUpdatePackagePhotographers(
      UpdatePackagePhotographers event, Emitter<StudioState> emit) {
    final updatedServices =
        List<StudioService>.from(state.currentEditingStudio.services);
    final updatedPackages =
        List<ServicePackage>.from(updatedServices[event.serviceIndex].packages);
    updatedPackages[event.packageIndex] =
        updatedPackages[event.packageIndex].copyWith(
      photographers: event.photographers,
    );
    updatedServices[event.serviceIndex] =
        updatedServices[event.serviceIndex].copyWith(
      packages: updatedPackages,
    );

    emit(StudioEditing(
      studios: state.studios,
      currentEditingStudio: state.currentEditingStudio.copyWith(
        services: updatedServices,
      ),
    ));
  }

  void _onUpdatePackageRate(
      UpdatePackageRate event, Emitter<StudioState> emit) {
    final updatedServices =
        List<StudioService>.from(state.currentEditingStudio.services);
    final updatedPackages =
        List<ServicePackage>.from(updatedServices[event.serviceIndex].packages);
    updatedPackages[event.packageIndex] =
        updatedPackages[event.packageIndex].copyWith(
      rate: event.rate,
    );
    updatedServices[event.serviceIndex] =
        updatedServices[event.serviceIndex].copyWith(
      packages: updatedPackages,
    );

    emit(StudioEditing(
      studios: state.studios,
      currentEditingStudio: state.currentEditingStudio.copyWith(
        services: updatedServices,
      ),
    ));
  }

  void _onRemovePackage(RemovePackage event, Emitter<StudioState> emit) {
    final updatedServices =
        List<StudioService>.from(state.currentEditingStudio.services);
    final updatedPackages =
        List<ServicePackage>.from(updatedServices[event.serviceIndex].packages);
    updatedPackages.removeAt(event.packageIndex);
    updatedServices[event.serviceIndex] =
        updatedServices[event.serviceIndex].copyWith(
      packages: updatedPackages,
    );

    emit(StudioEditing(
      studios: state.studios,
      currentEditingStudio: state.currentEditingStudio.copyWith(
        services: updatedServices,
      ),
    ));
  }
}
