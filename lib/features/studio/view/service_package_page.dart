import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/studio/model/studio_model.dart';
import 'package:rent_cam/features/studio/service/booking_service.dart';
import 'package:rent_cam/features/studio/view/service_package_detail_page.dart';
import 'package:rent_cam/features/studio/bloc/studio_booking_bloc/studio_booking_bloc.dart';
import 'package:rent_cam/features/chat/services/chat_service.dart';

class ServicePackagesPage extends StatelessWidget {
  final Studio studio;
  final StudioService service;

  const ServicePackagesPage({
    super.key,
    required this.studio,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isStudioOwner = currentUser != null &&
        studio.userId != null &&
        studio.userId == currentUser.uid;

    return Scaffold(
      appBar: CustomAppBar(
        title: service.name,
        backgroundColor: AppColors.cardGradientStart,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: service.packages.length,
        itemBuilder: (context, index) {
          final package = service.packages[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.name,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Photos', '${package.photoCount}'),
                  _buildDetailRow('Hours', '${package.workingHours}'),
                  _buildDetailRow('Photographers', '${package.photographers}'),
                  _buildDetailRow(
                      'Rate', '₹${package.rate.toStringAsFixed(2)}'),
                  const SizedBox(height: 16),
                  if (!isStudioOwner) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => StudioBookingBloc(
                                  bookingService: BookingService(),
                                  chatService: context.read<ChatService>(),
                                ),
                                child: ServicePackagePage(
                                  studio: studio,
                                  service: service,
                                  package: package,
                                ),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Book Now',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
