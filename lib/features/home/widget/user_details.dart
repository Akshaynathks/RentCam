import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/authentication/widget/validators.dart';
import 'package:rent_cam/features/home/bloc/user_details/user_details_bloc.dart';

class UserInfoSection extends StatelessWidget {
  final Map<String, dynamic> userDetails;

  const UserInfoSection({super.key, required this.userDetails});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final username = userDetails['name'] ?? 'Unknown';
    final phone = userDetails['phone'] ?? 'Unknown';
    final email = FirebaseAuth.instance.currentUser?.email ?? 'Unknown';

    return Container(
      height: screenHeight * 0.15,
      width: screenWidth * 0.65,
      decoration: BoxDecoration(
        color: AppColors.buttonText,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 9.0, top: 9.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(email),
                const SizedBox(height: 8),
                Text(phone),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditDialog(context, username, phone),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String currentName, String currentPhone) {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: currentName);
  final phoneController = TextEditingController(text: currentPhone);

  showDialog(
    context: context,
    builder: (context) {
      return BlocListener<UserDetailsBloc, UserDetailsState>(
        listener: (context, state) {
          if (state is UserDetailsLoaded) {
            Navigator.pop(context); 
            Navigator.pop(context); 
          } else if (state is UserDetailsError) {
            Navigator.pop(context); 
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: ${state.error}")),
            );
          }
        },
        child: AlertDialog(
          title: const Text("Edit Profile"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                  validator: validateFullName,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone"),
                  validator: validateMobile,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  final name = nameController.text.trim();
                  final phone = phoneController.text.trim();
                  context.read<UserDetailsBloc>().add(UpdateUserDetails(name, phone));
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      );
    },
  );
}
}
