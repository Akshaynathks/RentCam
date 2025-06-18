import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/chat/bloc/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:rent_cam/features/chat/services/chat_service.dart';
import 'package:rent_cam/features/chat/view/chat_detail_page.dart';
import 'package:rent_cam/features/studio/bloc/studio_bloc/studio_bloc.dart';
import 'package:rent_cam/features/studio/model/studio_model.dart';
import 'package:rent_cam/features/studio/view/add_studio.dart';
import 'package:rent_cam/features/studio/view/service_package_page.dart';
import 'package:rent_cam/features/studio/widget/service_card.dart';

class StudioDetailPage extends StatefulWidget {
  final Studio studio;
  final bool isOwner;

  const StudioDetailPage({
    super.key,
    required this.studio,
    required this.isOwner,
  });

  @override
  State<StudioDetailPage> createState() => _StudioDetailPageState();
}

class _StudioDetailPageState extends State<StudioDetailPage> {
  Future<void> _showDeleteConfirmation(BuildContext context) async {
    if (widget.studio.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Invalid studio ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Studio',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this studio? This action cannot be undone.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  if (context.mounted) {
                    // Show loading snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 16),
                            Text('Deleting studio...'),
                          ],
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // Add delete event and listen for the result
                    context
                        .read<StudioBloc>()
                        .add(DeleteStudio(widget.studio.id, context));

                    // Listen to the bloc state changes
                    context.read<StudioBloc>().stream.listen((state) {
                      if (state is StudioOperationSuccess) {
                        // Hide loading snackbar
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Studio deleted successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );

                        // Navigate back to studio page
                        if (context.mounted) {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        }
                      } else if (state is StudioOperationFailure) {
                        // Hide loading snackbar
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();

                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${state.error}'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    });
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudioBloc, StudioState>(
      builder: (context, state) {
        // Get the latest studio data from the bloc
        final updatedStudio = state.studios.firstWhere(
          (s) => s.id == widget.studio.id,
          orElse: () => widget.studio,
        );

        // Check if studio is blocked
        if (updatedStudio.isBlocked) {
          return Scaffold(
            appBar: CustomAppBar(
              title: 'Studio Blocked',
              showBackButton: true,
              backgroundColorGradient: const [
                AppColors.cardGradientStart,
                AppColors.cardGradientEnd,
              ],
              titleColor: AppColors.buttonText,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.block, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'This studio has been blocked by admin',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (updatedStudio.blockedReason != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Reason: ${updatedStudio.blockedReason}',
                        style: GoogleFonts.poppins(),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }

        final currentUser = FirebaseAuth.instance.currentUser;
        final isStudioOwner = currentUser != null &&
            updatedStudio.userId != null &&
            updatedStudio.userId == currentUser.uid;

        return Scaffold(
          appBar: CustomAppBar(
            title: updatedStudio.name,
            showBackButton: true,
            backgroundColorGradient: const [
              AppColors.cardGradientStart,
              AppColors.cardGradientEnd,
            ],
            titleColor: AppColors.buttonText,
            actions: isStudioOwner
                ? [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (String value) async {
                        if (value == 'edit') {
                          context
                              .read<StudioBloc>()
                              .add(StartEditingStudio(updatedStudio));
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: BlocProvider.of<StudioBloc>(context),
                                child: const AddStudioPage(),
                              ),
                            ),
                          );
                        } else if (value == 'delete') {
                          await _showDeleteConfirmation(context);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Edit Studio'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete Studio'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ]
                : null,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Studio Cover Image
                SizedBox(
                  height: 250,
                  child: PageView.builder(
                    itemCount: updatedStudio.trendingImages.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        updatedStudio.trendingImages[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),

                // Services Container
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardGradientEnd,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Our Services',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: GridView.builder(
                          scrollDirection: Axis.vertical,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: updatedStudio.services.length,
                          itemBuilder: (context, index) {
                            final service = updatedStudio.services[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ServiceCard(
                                service: service,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ServicePackagesPage(
                                        studio: updatedStudio,
                                        service: service,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Studio Details Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        updatedStudio.name,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                          Icons.location_on, updatedStudio.location),
                      const SizedBox(height: 8),
                      _buildDetailRow(Icons.phone, updatedStudio.phone),
                      const SizedBox(height: 8),
                      _buildDetailRow(Icons.email, updatedStudio.email),
                      const SizedBox(height: 24),

                      // Chat Button for non-owners
                      if (!isStudioOwner) ...[
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                final chatService = context.read<ChatService>();
                                final chatId = await chatService
                                    .getOrCreateChat(updatedStudio.userId);
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BlocProvider<ChatDetailBloc>(
                                        create: (context) => ChatDetailBloc(
                                          chatService: chatService,
                                        ),
                                        child: ChatDetailPage(chatId: chatId),
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.buttonPrimary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Chat With Studio',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.buttonText,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}
