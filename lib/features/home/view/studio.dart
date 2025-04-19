import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StudioPage extends StatelessWidget {
  const StudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 200.0,
            collapsedHeight: 60.0,
            toolbarHeight: 60.0,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                return FlexibleSpaceBar(
                  title: constraints.maxHeight > 120
                      ? null
                      : Text(
                          'Studios',
                          style: GoogleFonts.poppins(
                            color: AppColors.buttonText,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate().fadeIn(duration: 500.ms),
                  centerTitle: true,
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.cardGradientStart,
                          AppColors.indicatorInactive,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      left: 24.0,
                      right: 24.0,
                      top: 80.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Studios',
                          style: GoogleFonts.poppins(
                            color: AppColors.buttonText,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slide(begin: Offset(0, -0.5)),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            Text(
                              'Showcase your talent, connect',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                height: 1.2,
                                color: AppColors.buttonText,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            )
                                .animate()
                                .fadeIn(delay: 400.ms, duration: 1000.ms)
                                .slideX(begin: -0.5, duration: 1000.ms),
                            Text(
                              'and grow - add your',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                height: 1.2,
                                color: AppColors.buttonText,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            )
                                .animate()
                                .fadeIn(delay: 600.ms, duration: 1000.ms)
                                .slideX(begin: 0.5, duration: 1000.ms),
                            Text(
                              'studio and open doors to new collaboration',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                height: 1.2,
                                color: AppColors.buttonText,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            )
                                .animate()
                                .fadeIn(delay: 800.ms, duration: 1000.ms)
                                .slideX(begin: -0.5, duration: 1000.ms),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
            ).animate().fadeIn(duration: 500.ms),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz, color: Colors.white)
                    .animate()
                    .fadeIn(duration: 500.ms),
                onSelected: (String value) {
                  if (value == 'add') {
                    Navigator.pushNamed(context, '/addStudio');
                  } else if (value == 'edit') {
                    // Handle edit action
                    print('Edit option selected');
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'add',
                    child: Text('Add Studio'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit Studio'),
                  ),
                ],
              ),
            ],
          ),
          // You can add your main content here
          SliverFillRemaining(
            child: Container(), // Empty container or your actual content
          ),
        ],
      ),
    );
  }
}
