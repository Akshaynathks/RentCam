part of 'profile_image_bloc.dart';

@immutable
abstract class ProfileImageState {}

class ProfileImageInitial extends ProfileImageState {}

class ProfileImageUploading extends ProfileImageState {}

class ProfileImageSelected extends ProfileImageState {
  final File image;

  ProfileImageSelected(this.image);
}

class ProfileImageUploaded extends ProfileImageState {
  final String imageUrl;

  ProfileImageUploaded(this.imageUrl);
}

class ProfileImageFailure extends ProfileImageState {
  final String errorMessage;

  ProfileImageFailure(this.errorMessage);
}

class InitialProfileImageState extends ProfileImageState {
  final String iamgeurl;
  InitialProfileImageState({required this.iamgeurl});
}
