import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/studio/bloc/studio_booking_bloc/studio_booking_bloc.dart';
import 'package:rent_cam/features/studio/bloc/studio_booking_bloc/studio_booking_event.dart';
import 'package:rent_cam/features/studio/bloc/studio_booking_bloc/studio_booking_state.dart';
import 'package:rent_cam/features/studio/model/studio_model.dart';
import 'package:table_calendar/table_calendar.dart';

class ServicePackagePage extends StatefulWidget {
  final Studio studio;
  final StudioService service;
  final ServicePackage package;

  const ServicePackagePage({
    Key? key,
    required this.studio,
    required this.service,
    required this.package,
  }) : super(key: key);

  @override
  State<ServicePackagePage> createState() => _ServicePackagePageState();
}

class _ServicePackagePageState extends State<ServicePackagePage> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Set<DateTime> _selectedDates = {};
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    // Check if user is the studio owner
    final currentUser = FirebaseAuth.instance.currentUser;
    final isStudioOwner = currentUser != null &&
        widget.studio.userId != null &&
        widget.studio.userId == currentUser.uid;

    if (isStudioOwner) {
      // If user is the owner, pop back to previous screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Studio owners cannot book their own services'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (selectedDay
        .isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot select past dates')),
      );
      return;
    }

    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;

      if (_selectedDates.contains(selectedDay)) {
        _selectedDates.remove(selectedDay);
      } else {
        if (_selectedDates.length < 10) {
          _selectedDates.add(selectedDay);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maximum 10 dates can be selected')),
          );
        }
      }
    });
  }

  void _handleBooking() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one date')),
      );
      return;
    }

    context.read<StudioBookingBloc>().add(
          CreateStudioBooking(
            studio: widget.studio,
            service: widget.service,
            package: widget.package,
            selectedDates: _selectedDates.toList(),
            location: _locationController.text,
            context: context,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.package.name),
        backgroundColor: AppColors.cardGradientStart,
      ),
      body: BlocConsumer<StudioBookingBloc, StudioBookingState>(
        listener: (context, state) {
          if (state is StudioBookingFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Package Details',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                              'Photos', '${widget.package.photoCount}'),
                          _buildDetailRow(
                              'Hours', '${widget.package.workingHours}'),
                          _buildDetailRow('Photographers',
                              '${widget.package.photographers}'),
                          _buildDetailRow('Rate',
                              '₹${widget.package.rate.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Dates',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TableCalendar(
                            firstDay: DateTime.now(),
                            lastDay:
                                DateTime.now().add(const Duration(days: 365)),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) =>
                                _selectedDates.contains(day),
                            calendarFormat: _calendarFormat,
                            onFormatChanged: (format) {
                              setState(() {
                                _calendarFormat = format;
                              });
                            },
                            onDaySelected: _onDaySelected,
                            calendarStyle: const CalendarStyle(
                              selectedDecoration: BoxDecoration(
                                color: AppColors.buttonPrimary,
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: AppColors.indicatorInactive,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          if (_selectedDates.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Selected Dates:',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: _selectedDates
                                  .map((date) => Chip(
                                        label: Text(
                                          '${date.day}/${date.month}/${date.year}',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        backgroundColor:
                                            AppColors.buttonPrimary,
                                        deleteIcon: const Icon(Icons.close,
                                            color: Colors.white),
                                        onDeleted: () {
                                          setState(() {
                                            _selectedDates.remove(date);
                                          });
                                        },
                                      ))
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              hintText: 'Enter shooting location',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the location';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          state is StudioBookingLoading ? null : _handleBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: state is StudioBookingLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Confirm Booking',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
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
