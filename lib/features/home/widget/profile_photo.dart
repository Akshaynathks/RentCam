import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:rent_cam/features/home/bloc/profile_photo/profile_image_bloc.dart';

class CircleAvatarSection extends StatelessWidget {
  const CircleAvatarSection({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ProfileImageBloc>().add(ProfileImageInitilizeEvent());

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            BlocConsumer<ProfileImageBloc, ProfileImageState>(
              listener: (context, state) {
                if (state is ProfileImageSelected) {
                  print('Image selected');
                  showUploadDialog(context, state.image, getCurrentUserId()!);
                }
              },
              builder: (context, state) {
                if (state is InitialProfileImageState &&
                    state.iamgeurl.isNotEmpty) {
                  return CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(state.iamgeurl),
                  );
                } else if (state is ProfileImageUploading) {
                  return const CircularProgressIndicator();
                } else if (state is ProfileImageUploaded) {
                  return CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(state.imageUrl),
                  );
                } else if (state is ProfileImageSelected) {
                  return CircleAvatar(
                    radius: 50,
                    backgroundImage: FileImage(state.image),
                  );
                } else {
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(
                      child: Lottie.asset(
                        'assets/images/Animation - user.json',
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }
              },
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add_a_photo, color: Colors.blue),
                  onPressed: () {
                    context
                        .read<ProfileImageBloc>()
                        .add(SelectProfileImageEvent());
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

void showUploadDialog(BuildContext context, File image, String uid) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Upload Image"),
      content: const Text("Do you want to upload this image?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            context
                .read<ProfileImageBloc>()
                .add(UploadProfileImageEvent(image: image, uid: uid));
            Navigator.of(context).pop();
          },
          child: const Text("Upload"),
        ),
      ],
    ),
  );
}

String? getCurrentUserId() {
  final user = FirebaseAuth.instance.currentUser;
  return user?.uid;
}
