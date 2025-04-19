import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:rent_cam/features/home/services/profile_photo.dart';

part 'profile_image_event.dart';
part 'profile_image_state.dart';

class ProfileImageBloc extends Bloc<ProfileImageEvent, ProfileImageState> {
  final ImagePicker _picker = ImagePicker();

  ProfileImageBloc() : super(ProfileImageInitial()) {
    on<SelectProfileImageEvent>((event, emit) async {
      try {
        final XFile? pickedFile =
            await _picker.pickImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          print(pickedFile.path);
          emit(ProfileImageSelected(File(pickedFile.path)));
        } else {
          emit(ProfileImageFailure("No image selected"));
        }
      } catch (e) {
        emit(ProfileImageFailure("Failed to pick an image: ${e.toString()}"));
      }
    });

    on<UploadProfileImageEvent>((event, emit) async {
      emit(ProfileImageUploading());
      try {
        final imageUrl = await CloudinaryService.uploadImage(event.image);
        if (imageUrl != null) {
          emit(ProfileImageUploaded(imageUrl));
          add(UpdateFirestoreWithImageEvent(
              uid: event.uid, imageUrl: imageUrl));
        } else {
          emit(ProfileImageFailure("Image upload failed"));
        }
      } catch (e) {
        emit(ProfileImageFailure("Error uploading image: ${e.toString()}"));
      }
    });

    on<ClearProfileImageEvent>((event, emit) {
      emit(ProfileImageInitial());
    });

    on<UpdateFirestoreWithImageEvent>((event, emit) async {
      try {
        await FirestoreService.updateUserImage(event.uid, event.imageUrl);
        emit(ProfileImageUploaded(event.imageUrl));
      } catch (e) {
        emit(
            ProfileImageFailure("Failed to update Firestore: ${e.toString()}"));
      }
    });

    on<ProfileImageInitilizeEvent>((event, emit) async {
      final image = await getCurrentUserImageUrl();
      if (image != null && image.isNotEmpty) {
        emit(InitialProfileImageState(iamgeurl: image));
      } else {
        emit(ProfileImageInitial());
      }
    });
  }
}

Future<String?> getCurrentUserImageUrl() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('No user is signed in.');
      return null; 
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data();
      if (data != null && data.containsKey('imageUrl')) {
        return data['imageUrl'] as String;
      } else {
        print('imageUrl not found in user document.');
        return null;
      }
    } else {
      print('User document does not exist.');
      return null;
    }
  } catch (e) {
    print('Error fetching imageUrl: $e');
    return null;
  }
}
