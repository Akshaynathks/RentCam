import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_cam/core/utils/responsive_helper.dart';
import 'package:rent_cam/features/studio/model/studio_model.dart';

class StudioCard extends StatefulWidget {
  final Studio studio;
  final bool isOwner;
  final VoidCallback onTap;

  const StudioCard({
    super.key,
    required this.studio,
    required this.isOwner,
    required this.onTap,
  });

  @override
  State<StudioCard> createState() => _StudioCardState();
}

class _StudioCardState extends State<StudioCard> {
  int _currentImageIndex = 0;
  late final PageController _pageController;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (widget.studio.trendingImages.length > 1) {
      _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_pageController.hasClients) {
          int nextPage = _currentImageIndex + 1;
          if (nextPage >= widget.studio.trendingImages.length) {
            nextPage = 0;
          }
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
          setState(() {
            _currentImageIndex = nextPage;
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant StudioCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.studio.trendingImages.length !=
        widget.studio.trendingImages.length) {
      _currentImageIndex = 0;
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal:
            ResponsiveHelper.getResponsivePadding(context).horizontal / 16,
        vertical: ResponsiveHelper.getResponsivePadding(context).vertical / 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: ResponsiveHelper.getResponsiveImageHeight(context) * 1.2,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12.0),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12.0),
                ),
                child: widget.studio.trendingImages.isNotEmpty
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: widget.studio.trendingImages.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Image.network(
                                widget.studio.trendingImages[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: ResponsiveHelper
                                          .getResponsiveIconSize(context, 50),
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          if (widget.studio.trendingImages.length > 1)
                            Positioned(
                              bottom: 8,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  widget.studio.trendingImages.length,
                                  (index) => Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentImageIndex == index
                                          ? Theme.of(context).primaryColor
                                          : Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    : Image.asset(
                        'assets/placeholder.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: ResponsiveHelper.getResponsiveIconSize(
                                  context, 50),
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
              ),
            ),
            Padding(
              padding: ResponsiveHelper.getResponsivePadding(context)
                  .copyWith(top: 4, bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.studio.name.isNotEmpty
                              ? widget.studio.name
                              : 'Unnamed Studio',
                          style: GoogleFonts.poppins(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context, 18),
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      height:
                          ResponsiveHelper.getResponsiveHeight(context, 0.5)),
                  Text(
                    widget.studio.location.isNotEmpty
                        ? widget.studio.location
                        : 'Location not specified',
                    style: GoogleFonts.poppins(
                      fontSize:
                          ResponsiveHelper.getResponsiveFontSize(context, 14),
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                      height:
                          ResponsiveHelper.getResponsiveHeight(context, 0.5)),
                  if (widget.studio.services.isNotEmpty)
                    Text(
                      'Services: ${widget.studio.services.map((s) => s.name).join(', ')}',
                      style: GoogleFonts.poppins(
                        fontSize:
                            ResponsiveHelper.getResponsiveFontSize(context, 12),
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
