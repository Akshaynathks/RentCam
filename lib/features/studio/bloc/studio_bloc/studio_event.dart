part of 'studio_bloc.dart';

abstract class StudioEvent extends Equatable {
  const StudioEvent();

  @override
  List<Object> get props => [];
}

class LoadStudios extends StudioEvent {
  const LoadStudios();
}

class AddStudio extends StudioEvent {
  final Studio studio;
  final BuildContext context;

  const AddStudio(this.studio, this.context);

  @override
  List<Object> get props => [studio, context];
}

class UpdateStudio extends StudioEvent {
  final Studio studio;
  final BuildContext context;

  const UpdateStudio(this.studio, this.context);

  @override
  List<Object> get props => [studio, context];
}

class StartEditingStudio extends StudioEvent {
  final Studio? studio;

  const StartEditingStudio([this.studio]);

  @override
  List<Object> get props => studio != null ? [studio!] : [];
}

class CancelEditingStudio extends StudioEvent {
  const CancelEditingStudio();
}

class AddTrendingImage extends StudioEvent {
  final String imageUrl;

  const AddTrendingImage(this.imageUrl);

  @override
  List<Object> get props => [imageUrl];
}

class RemoveTrendingImage extends StudioEvent {
  final String imageUrl;

  const RemoveTrendingImage(this.imageUrl);

  @override
  List<Object> get props => [imageUrl];
}

class AddService extends StudioEvent {
  const AddService();
}

class RemoveService extends StudioEvent {
  final int serviceIndex;

  const RemoveService(this.serviceIndex);

  @override
  List<Object> get props => [serviceIndex];
}

class AddPackage extends StudioEvent {
  final int serviceIndex;

  const AddPackage(this.serviceIndex);

  @override
  List<Object> get props => [serviceIndex];
}

class UpdateServiceName extends StudioEvent {
  final int serviceIndex;
  final String name;

  const UpdateServiceName(this.serviceIndex, this.name);

  @override
  List<Object> get props => [serviceIndex, name];
}

class UpdateServiceImage extends StudioEvent {
  final int serviceIndex;
  final String imageUrl;

  const UpdateServiceImage(this.serviceIndex, this.imageUrl);

  @override
  List<Object> get props => [serviceIndex, imageUrl];
}

class UpdatePackageName extends StudioEvent {
  final int serviceIndex;
  final int packageIndex;
  final String name;

  const UpdatePackageName(this.serviceIndex, this.packageIndex, this.name);

  @override
  List<Object> get props => [serviceIndex, packageIndex, name];
}

class UpdatePackagePhotoCount extends StudioEvent {
  final int serviceIndex;
  final int packageIndex;
  final int photoCount;

  const UpdatePackagePhotoCount(
      this.serviceIndex, this.packageIndex, this.photoCount);

  @override
  List<Object> get props => [serviceIndex, packageIndex, photoCount];
}

class UpdatePackageWorkingHours extends StudioEvent {
  final int serviceIndex;
  final int packageIndex;
  final int workingHours;

  const UpdatePackageWorkingHours(
      this.serviceIndex, this.packageIndex, this.workingHours);

  @override
  List<Object> get props => [serviceIndex, packageIndex, workingHours];
}

class UpdatePackagePhotographers extends StudioEvent {
  final int serviceIndex;
  final int packageIndex;
  final int photographers;

  const UpdatePackagePhotographers(
      this.serviceIndex, this.packageIndex, this.photographers);

  @override
  List<Object> get props => [serviceIndex, packageIndex, photographers];
}

class UpdatePackageRate extends StudioEvent {
  final int serviceIndex;
  final int packageIndex;
  final double rate;

  const UpdatePackageRate(this.serviceIndex, this.packageIndex, this.rate);

  @override
  List<Object> get props => [serviceIndex, packageIndex, rate];
}

class RemovePackage extends StudioEvent {
  final int serviceIndex;
  final int packageIndex;

  const RemovePackage(this.serviceIndex, this.packageIndex);

  @override
  List<Object> get props => [serviceIndex, packageIndex];
}

class DeleteStudio extends StudioEvent {
  final String studioId;
  final BuildContext context;

  const DeleteStudio(this.studioId, this.context);

  @override
  List<Object> get props => [studioId, context];
}
