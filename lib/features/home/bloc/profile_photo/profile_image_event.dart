part of 'profile_image_bloc.dart';

@immutable
abstract class ProfileImageEvent {}

class SelectProfileImageEvent extends ProfileImageEvent {}

class UploadProfileImageEvent extends ProfileImageEvent {
  final File image;
  final String uid;

  UploadProfileImageEvent({required this.image, required this.uid});
}

class ClearProfileImageEvent extends ProfileImageEvent {}

class UpdateFirestoreWithImageEvent extends ProfileImageEvent {
  final String uid;
  final String imageUrl;

  UpdateFirestoreWithImageEvent({required this.uid, required this.imageUrl});
}


class ProfileImageInitilizeEvent extends ProfileImageEvent{
  
}