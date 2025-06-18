import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/authentication/widget/validators.dart';
import 'package:rent_cam/features/studio/bloc/studio_bloc/studio_bloc.dart';
import 'package:rent_cam/features/studio/model/studio_model.dart';
import 'package:rent_cam/features/home/services/profile_photo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_cam/features/studio/view/service_package_page.dart';

class PackageControllers {
  final TextEditingController nameController;
  final TextEditingController photoCountController;
  final TextEditingController workingHoursController;
  final TextEditingController photographersController;
  final TextEditingController rateController;

  PackageControllers({
    required this.nameController,
    required this.photoCountController,
    required this.workingHoursController,
    required this.photographersController,
    required this.rateController,
  });

  void dispose() {
    nameController.dispose();
    photoCountController.dispose();
    workingHoursController.dispose();
    photographersController.dispose();
    rateController.dispose();
  }
}

class AddStudioPage extends StatefulWidget {
  const AddStudioPage({super.key});

  @override
  State<AddStudioPage> createState() => _AddStudioPageState();
}

class _AddStudioPageState extends State<AddStudioPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final Map<int, Map<int, PackageControllers>> _packageControllers = {};
  final Map<int, TextEditingController> _serviceNameControllers = {};
  final _buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonPrimary,
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  );

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing studio data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentStudio =
          context.read<StudioBloc>().state.currentEditingStudio;
      if (currentStudio.id.isNotEmpty) {
        // This is editing an existing studio
        _nameController.text = currentStudio.name;
        _phoneController.text = currentStudio.phone;
        _emailController.text = currentStudio.email;
        _locationController.text = currentStudio.location;

        // Update the app bar title to reflect editing mode
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // Reset the editing state when leaving the page without saving
    final currentState = context.read<StudioBloc>().state;
    if (currentState is StudioEditing &&
        currentState.currentEditingStudio.id.isNotEmpty) {
      // Only reset if we're in editing mode and haven't saved
      context.read<StudioBloc>().add(const CancelEditingStudio());
    }

    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();

    for (var serviceControllers in _packageControllers.values) {
      for (var packageController in serviceControllers.values) {
        packageController.dispose();
      }
    }
    _packageControllers.clear();

    for (var controller in _serviceNameControllers.values) {
      controller.dispose();
    }
    _serviceNameControllers.clear();

    super.dispose();
  }

  Future<void> _pickImage(StudioState currentState) async {
    try {
      print('Starting image picker...');
      final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage(
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFiles == null || pickedFiles.isEmpty) {
        print('No images selected');
        return;
      }

      print('Selected ${pickedFiles.length} images');
      if (!mounted) return;

      // Show initial loading snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(width: 10),
              Text('Starting image upload...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      int successCount = 0;
      int failCount = 0;

      for (final pickedFile in pickedFiles) {
        try {
          print('Processing image: ${pickedFile.path}');
          if (!await File(pickedFile.path).exists()) {
            print('File does not exist: ${pickedFile.path}');
            failCount++;
            continue;
          }

          final imageUrl =
              await CloudinaryService.uploadImage(File(pickedFile.path));
          if (imageUrl != null && mounted) {
            print('Successfully uploaded image: $imageUrl');
            context.read<StudioBloc>().add(AddTrendingImage(imageUrl));
            successCount++;
          } else {
            print('Failed to get image URL for: ${pickedFile.path}');
            failCount++;
          }
        } catch (e) {
          print('Error processing image ${pickedFile.path}: $e');
          failCount++;
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show final status
      if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully uploaded $successCount image${successCount > 1 ? 's' : ''}' +
                  (failCount > 0
                      ? '. Failed to upload $failCount image${failCount > 1 ? 's' : ''}'
                      : ''),
            ),
            backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else if (failCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to upload $failCount image${failCount > 1 ? 's' : ''}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error in _pickImage: $e');
      print('Stack trace: $stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting images: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _addService() {
    context.read<StudioBloc>().add(AddService());
  }

  void _addPackage(int serviceIndex) {
    context.read<StudioBloc>().add(AddPackage(serviceIndex));
  }

  void _saveStudio(Studio currentStudio) {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields correctly'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (currentStudio.trendingImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one trending image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (currentStudio.services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one service'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate each service has at least one package
    for (var service in currentStudio.services) {
      if (service.packages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Each service must have at least one package'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final studio = currentStudio.copyWith(
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      location: _locationController.text,
    );

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text(studio.id.isNotEmpty
                ? 'Updating studio...'
                : 'Saving studio...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // Check if this is an update or a new studio
    if (studio.id.isNotEmpty) {
      // This is an update to an existing studio
      context.read<StudioBloc>().add(UpdateStudio(studio, context));
    } else {
      // This is a new studio - check if user already has one
      final currentState = context.read<StudioBloc>().state;
      final currentUser = FirebaseAuth.instance.currentUser;
      final hasExistingStudio = currentState.studios.any(
        (s) => s.userId == currentUser?.uid,
      );

      if (hasExistingStudio) {
        // Hide loading snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // Show message that user already has a studio
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You can only have one studio. Please edit your existing studio instead.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
        return;
      }

      // User doesn't have a studio, proceed with adding
      context.read<StudioBloc>().add(AddStudio(studio, context));
    }
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? prefixIcon,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon,
          filled: true,
          fillColor: Colors.white,
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFFC107), width: 2.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 17.0,
            vertical: 16.0,
          ),
        ),
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudioBloc, StudioState>(
      listener: (context, state) {
        // Update controllers when studio data changes for editing
        if (state.currentEditingStudio.id.isNotEmpty) {
          final studio = state.currentEditingStudio;
          if (_nameController.text != studio.name) {
            _nameController.text = studio.name;
            _phoneController.text = studio.phone;
            _emailController.text = studio.email;
            _locationController.text = studio.location;
          }
        }

        if (state is StudioOperationSuccess) {
          // Check if this was a successful studio addition/update
          if (state.currentEditingStudio.id.isEmpty) {
            // This means we just added a new studio successfully
            if (context.mounted) {
              // First check if we can pop
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                // If we can't pop, navigate to the studio page
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/studios',
                  (route) => false, // Remove all previous routes
                );
              }
            }
          }
        } else if (state is StudioOperationFailure) {
          // Show error message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error ?? 'An error occurred',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        final currentStudio = state.currentEditingStudio;

        return Scaffold(
          appBar: CustomAppBar(
            title: currentStudio.id.isNotEmpty ? 'Edit Studio' : 'Add Studio',
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Studio Information'),
                      _buildCustomTextField(
                        controller: _nameController,
                        hintText: 'Studio Name',
                        validator: validateStudioName,
                        onChanged: (value) {
                          setState(
                              () {}); // Trigger rebuild for real-time validation
                        },
                      ),
                      _buildCustomTextField(
                        controller: _phoneController,
                        hintText: 'Phone Number',
                        keyboardType: TextInputType.phone,
                        validator: validateMobile,
                        onChanged: (value) {
                          setState(
                              () {}); // Trigger rebuild for real-time validation
                        },
                      ),
                      _buildCustomTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: validateEmail,
                        onChanged: (value) {
                          setState(
                              () {}); // Trigger rebuild for real-time validation
                        },
                      ),
                      _buildCustomTextField(
                        controller: _locationController,
                        hintText: 'Location',
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.map,
                              color: Colors.white, size: 20),
                          label: const Text('Select Location',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14)),
                          style: _buttonStyle,
                          onPressed: () {},
                        ),
                      ),
                      _buildSectionTitle('Trending Images'),
                      Wrap(
                        children: [
                          ...currentStudio.trendingImages.map((image) =>
                              _buildImagePreview(image, currentStudio)),
                          IconButton(
                            icon: const Icon(Icons.add_photo_alternate,
                                color: Colors.white),
                            onPressed: () => _pickImage(state),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.buttonPrimary,
                            ),
                          ),
                        ],
                      ),
                      _buildSectionTitle('Services'),
                      ...currentStudio.services.asMap().entries.map((entry) {
                        final index = entry.key;
                        final service = entry.value;
                        return _buildServiceCard(index, service, currentStudio);
                      }).toList(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addService,
                          style: _buttonStyle,
                          child: const Text(
                            'Add Service',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 200,
                            maxWidth: 300,
                          ),
                          child: ElevatedButton(
                            onPressed: () => _saveStudio(currentStudio),
                            style: _buttonStyle,
                            child: Text(
                              currentStudio.id.isNotEmpty
                                  ? 'Update Studio'
                                  : 'Save Studio',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildImagePreview(String imageUrl, Studio studio) {
    print('Building image preview for: $imageUrl');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  print('Error loading image: $imageUrl');
                  print('Error details: $exception');
                  print('Stack trace: $stackTrace');
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Error loading image: ${exception.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                print('Removing image: $imageUrl');
                context.read<StudioBloc>().add(RemoveTrendingImage(imageUrl));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(int index, StudioService service, Studio studio) {
    _serviceNameControllers[index] ??=
        TextEditingController(text: service.name);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomTextField(
              controller: _serviceNameControllers[index]!,
              hintText: 'Service Name',
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Service name is required' : null,
              onChanged: (value) {
                context.read<StudioBloc>().add(UpdateServiceName(index, value));
              },
            ),
            const SizedBox(height: 10),
            const Text('Service Image:',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
            if (service.image.isNotEmpty)
              _buildImagePreview(service.image, studio),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_photo_alternate,
                    color: Colors.white, size: 20),
                label: const Text('Add Service Image',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                style: _buttonStyle,
                onPressed: () async {
                  try {
                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                      maxWidth: 1200,
                      maxHeight: 1200,
                    );

                    if (pickedFile != null) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(width: 10),
                              Text('Uploading service image...'),
                            ],
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );

                      final imageUrl = await CloudinaryService.uploadImage(
                          File(pickedFile.path));
                      if (imageUrl != null && mounted) {
                        context
                            .read<StudioBloc>()
                            .add(UpdateServiceImage(index, imageUrl));
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Service image uploaded successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Error uploading service image: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            const Text('Packages:',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
            ...service.packages.asMap().entries.map((entry) {
              final pkgIndex = entry.key;
              final package = entry.value;
              return _buildPackageForm(index, pkgIndex, package);
            }).toList(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _addPackage(index),
                style: _buttonStyle,
                child: const Text(
                  'Add Package',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServicePackagesPage(
                        studio: studio,
                        service: service,
                      ),
                    ),
                  );
                },
                style: _buttonStyle,
                child: const Text(
                  'View Packages',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageForm(
      int serviceIndex, int packageIndex, ServicePackage package) {
    _packageControllers[serviceIndex] ??= {};
    _packageControllers[serviceIndex]![packageIndex] ??= PackageControllers(
      nameController: TextEditingController(text: package.name),
      photoCountController: TextEditingController(
          text: package.photoCount > 0 ? package.photoCount.toString() : ''),
      workingHoursController: TextEditingController(
          text:
              package.workingHours > 0 ? package.workingHours.toString() : ''),
      photographersController: TextEditingController(
          text: package.photographers > 0
              ? package.photographers.toString()
              : ''),
      rateController: TextEditingController(
          text: package.rate > 0 ? package.rate.toString() : ''),
    );

    final controllers = _packageControllers[serviceIndex]![packageIndex]!;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCustomTextField(
              controller: controllers.nameController,
              hintText: 'Package Name',
              onChanged: (value) {
                context
                    .read<StudioBloc>()
                    .add(UpdatePackageName(serviceIndex, packageIndex, value));
              },
            ),
            _buildCustomTextField(
              controller: controllers.photoCountController,
              hintText: 'Number of Photos',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                context.read<StudioBloc>().add(UpdatePackagePhotoCount(
                    serviceIndex, packageIndex, int.tryParse(value) ?? 0));
              },
            ),
            _buildCustomTextField(
              controller: controllers.workingHoursController,
              hintText: 'Max Working Hours',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                context.read<StudioBloc>().add(UpdatePackageWorkingHours(
                    serviceIndex, packageIndex, int.tryParse(value) ?? 0));
              },
            ),
            _buildCustomTextField(
              controller: controllers.photographersController,
              hintText: 'Total Photographers',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                context.read<StudioBloc>().add(UpdatePackagePhotographers(
                    serviceIndex, packageIndex, int.tryParse(value) ?? 0));
              },
            ),
            _buildCustomTextField(
              controller: controllers.rateController,
              hintText: 'Rate',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                context.read<StudioBloc>().add(UpdatePackageRate(
                    serviceIndex, packageIndex, double.tryParse(value) ?? 0.0));
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Dispose controllers when package is removed
                _packageControllers[serviceIndex]?[packageIndex]?.dispose();
                _packageControllers[serviceIndex]?.remove(packageIndex);
                context
                    .read<StudioBloc>()
                    .add(RemovePackage(serviceIndex, packageIndex));
              },
            ),
          ],
        ),
      ),
    );
  }
}
