import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:rent_cam/features/studio/bloc/studio_bloc/studio_bloc.dart';
import 'package:rent_cam/features/studio/view/add_studio.dart';
import 'package:rent_cam/features/studio/view/studio_detail_page.dart';
import 'package:rent_cam/features/studio/model/studio_model.dart';
import 'package:rent_cam/core/utils/responsive_helper.dart';
import 'package:rent_cam/features/studio/widget/studio_card.dart';

class StudioPage extends StatelessWidget {
  const StudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final screenHeight = ResponsiveHelper.getScreenHeight(context);
    final screenWidth = ResponsiveHelper.getScreenWidth(context);

    return BlocListener<StudioBloc, StudioState>(
      listener: (context, state) {
        // If we're in editing state and the user navigates back,
        // we need to ensure the studios are loaded
        if (state is StudioEditing && state.studios.isEmpty) {
          // Refresh the studios list
          context.read<StudioBloc>().add(const LoadStudios());
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Lottie Background
            Positioned.fill(
              child: Lottie.asset(
                'assets/images/Animation - chat_back.json',
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),
            // Content
            CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  pinned: true,
                  expandedHeight:
                      ResponsiveHelper.isMobile(context) ? 200.0 : 300.0,
                  collapsedHeight: 60.0,
                  toolbarHeight: 60.0,
                  flexibleSpace: LayoutBuilder(
                    builder: (context, constraints) {
                      return FlexibleSpaceBar(
                        title: constraints.maxHeight >
                                (ResponsiveHelper.isMobile(context) ? 120 : 180)
                            ? null
                            : Text(
                                'Studios',
                                style: GoogleFonts.poppins(
                                  color: AppColors.buttonText,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 24),
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
                          padding: EdgeInsets.only(
                            left: ResponsiveHelper.getResponsivePadding(context)
                                .left,
                            right:
                                ResponsiveHelper.getResponsivePadding(context)
                                    .right,
                            top: ResponsiveHelper.isMobile(context)
                                ? 80.0
                                : 120.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Studios',
                                style: GoogleFonts.poppins(
                                  color: AppColors.buttonText,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 24),
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 500.ms)
                                  .slide(begin: const Offset(0, -0.5)),
                              SizedBox(
                                  height: ResponsiveHelper.getResponsiveHeight(
                                      context, 2)),
                              Column(
                                children: [
                                  Text(
                                    'Showcase your talent, connect',
                                    style: GoogleFonts.poppins(
                                      fontSize: ResponsiveHelper
                                          .getResponsiveFontSize(context, 18),
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
                                      fontSize: ResponsiveHelper
                                          .getResponsiveFontSize(context, 18),
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
                                      fontSize: ResponsiveHelper
                                          .getResponsiveFontSize(context, 18),
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
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: ResponsiveHelper.getResponsiveIconSize(context, 24),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/home');
                    },
                  ).animate().fadeIn(duration: 500.ms),
                  actions: [
                    Builder(
                      builder: (context) {
                        final currentUser = FirebaseAuth.instance.currentUser;

                        if (currentUser != null) {
                          return BlocBuilder<StudioBloc, StudioState>(
                            builder: (context, state) {
                              // Check if user already has a studio
                              final userStudio = state.studios
                                  .where(
                                    (studio) =>
                                        studio.userId == currentUser.uid,
                                  )
                                  .firstOrNull;
                              final hasStudio = userStudio != null;

                              return PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_horiz,
                                  color: Colors.white,
                                  size: ResponsiveHelper.getResponsiveIconSize(
                                      context, 24),
                                ).animate().fadeIn(duration: 500.ms),
                                onSelected: (String value) {
                                  if (value == 'add') {
                                    if (hasStudio) {
                                      // Show message that user already has a studio
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'You can only have one studio. Please edit your existing studio instead.',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: Colors.orange,
                                          duration: Duration(seconds: 4),
                                          action: SnackBarAction(
                                            label: 'Edit Studio',
                                            textColor: Colors.white,
                                            onPressed: () {
                                              // Load the existing studio for editing
                                              context.read<StudioBloc>().add(
                                                  StartEditingStudio(
                                                      userStudio));
                                              // Navigate to edit the existing studio
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      BlocProvider.value(
                                                    value: BlocProvider.of<
                                                        StudioBloc>(context),
                                                    child:
                                                        const AddStudioPage(),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    } else {
                                      // User doesn't have a studio, allow adding
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              BlocProvider.value(
                                            value: BlocProvider.of<StudioBloc>(
                                                context),
                                            child: const AddStudioPage(),
                                          ),
                                        ),
                                      );
                                    }
                                  } else if (value == 'edit') {
                                    if (hasStudio) {
                                      // Load the existing studio for editing
                                      context
                                          .read<StudioBloc>()
                                          .add(StartEditingStudio(userStudio));
                                      // Navigate to edit the existing studio
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              BlocProvider.value(
                                            value: BlocProvider.of<StudioBloc>(
                                                context),
                                            child: const AddStudioPage(),
                                          ),
                                        ),
                                      );
                                    } else {
                                      // Show message that user doesn't have a studio to edit
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'You don\'t have a studio yet. Please add one first.',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: Colors.blue,
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem<String>(
                                    value: 'add',
                                    child: Row(
                                      children: [
                                        Icon(
                                          hasStudio ? Icons.info : Icons.add,
                                          color: hasStudio
                                              ? Colors.orange
                                              : Colors.green,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            hasStudio
                                                ? 'Already have a studio'
                                                : 'Add Studio',
                                            style: TextStyle(
                                              fontSize: ResponsiveHelper
                                                  .getResponsiveFontSize(
                                                      context, 16),
                                              color: hasStudio
                                                  ? Colors.orange
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(
                                          hasStudio ? Icons.edit : Icons.info,
                                          color: hasStudio
                                              ? Colors.blue
                                              : Colors.grey,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            hasStudio
                                                ? 'Edit My Studio'
                                                : 'No studio to edit',
                                            style: TextStyle(
                                              fontSize: ResponsiveHelper
                                                  .getResponsiveFontSize(
                                                      context, 16),
                                              color: hasStudio
                                                  ? null
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        return Container();
                      },
                    ),
                  ],
                ),
                SliverPadding(
                  padding: ResponsiveHelper.getResponsivePadding(context),
                  sliver: BlocBuilder<StudioBloc, StudioState>(
                    builder: (context, state) {
                      // Handle both StudioOperationSuccess and StudioEditing states
                      List<Studio> studios = [];
                      if (state is StudioOperationSuccess) {
                        studios = state.studios;
                      } else if (state is StudioEditing) {
                        studios = state.studios;
                      }

                      if (studios.isEmpty) {
                        if (state is StudioLoading) {
                          return const SliverFillRemaining(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else if (state is StudioOperationFailure) {
                          return SliverFillRemaining(
                            child: Center(
                              child: Text(
                                'Error loading studios: ${state.error}',
                                style: GoogleFonts.poppins(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 18),
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return SliverFillRemaining(
                            child: Center(
                              child: Text(
                                'No studios added yet',
                                style: GoogleFonts.poppins(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                          context, 18),
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        }
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final studio = studios[index];
                            final isStudioOwner = currentUser != null &&
                                studio.userId != null &&
                                studio.userId == currentUser.uid;

                            return Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: ResponsiveHelper.getResponsivePadding(
                                            context)
                                        .vertical /
                                    2,
                              ),
                              child: StudioCard(
                                studio: studio,
                                isOwner: isStudioOwner,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StudioDetailPage(
                                        studio: studio,
                                        isOwner: isStudioOwner,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          childCount: studios.length,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
