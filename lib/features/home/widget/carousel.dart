import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:rent_cam/core/widget/shimmer.dart';
import 'package:rent_cam/features/home/model/offer_model.dart';
import 'package:rent_cam/features/home/view/offer_page.dart';

class CustomCarousel extends StatelessWidget {
  final List<Offer> offers;

  const CustomCarousel({
    Key? key,
    required this.offers,
    required List<String> imagePaths,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return offers.isEmpty
        ? ShimmerEffect.rectangular(height: 180) // Shimmer for empty state
        : CarouselSlider(
            options: CarouselOptions(
              height: 180,
              viewportFraction: 0.8,
              initialPage: 0,
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 1000),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              enlargeFactor: 0.2,
              scrollDirection: Axis.horizontal,
            ),
            items: offers.map((offer) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OfferPage(offer: offer),
                    ),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: offer.imageUrl == null || offer.imageUrl!.isEmpty
                        ? ShimmerEffect.rectangular(
                            height: 180) // Shimmer while loading
                        : Image.network(
                            offer.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return ShimmerEffect.rectangular(
                                  height: 180); // Shimmer while loading
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(child: Icon(Icons.error));
                            },
                          ),
                  ),
                ),
              );
            }).toList(),
          );
  }
}
