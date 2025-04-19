import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/core/widget/button.dart';
import 'package:rent_cam/features/home/bloc/offer_bloc/offer_bloc.dart';
import 'package:rent_cam/core/widget/appbar.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/home/model/offer_model.dart';
import 'package:rent_cam/features/home/widget/offer_card.dart';

class OfferPage extends StatelessWidget {
  final Offer? offer;
  const OfferPage({super.key, this.offer});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OfferBloc()..add(FetchOffers()),
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Offer Details',
          showBackButton: true,
        ),
        body: BlocBuilder<OfferBloc, OfferState>(
          builder: (context, state) {
            if (state is OfferLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OfferError) {
              return Center(child: Text(state.message));
            } else if (state is OfferLoaded) {
              return OfferContent(
                  offers: state.offers, selectedOffer: state.selectedOffer);
            } else {
              return const Center(child: Text('Unknown state'));
            }
          },
        ),
      ),
    );
  }
}

class OfferContent extends StatefulWidget {
  final List<Offer> offers;
  final Offer? selectedOffer;

  const OfferContent({super.key, required this.offers, this.selectedOffer});

  @override
  State<OfferContent> createState() => _OfferContentState();
}

class _OfferContentState extends State<OfferContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(OfferContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedOffer != null &&
        widget.selectedOffer != oldWidget.selectedOffer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      children: [
        if (widget.selectedOffer != null)
          Container(
            height: 320,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.cardGradientEnd,
                  AppColors.cardGradientStart,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: widget.selectedOffer!.imageUrl != null
                        ? Image.network(
                            widget.selectedOffer!.imageUrl!,
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image, size: 150),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Coupon Code:   ',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.buttonText),
                    ),
                    Text(
                      widget.selectedOffer!.couponCode,
                      style: const TextStyle(
                          fontSize: 20, color: AppColors.buttonPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.selectedOffer!.percentage}% OFF',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error),
                ),
                const SizedBox(height: 10),
                CustomElevatedButton(
                  text: 'Copy & Apply Code',
                  onPressed: () {
                    // Copy to clipboard
                    context
                        .read<OfferBloc>()
                        .add(CopyToClipboard(widget.selectedOffer!.couponCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Copied: ${widget.selectedOffer!.couponCode}')),
                    );

                    // Return the offer to the previous screen
                    Navigator.pop(context, widget.selectedOffer);
                  },
                  icon: const Icon(Icons.copy),
                  width: 250,
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        ...widget.offers.map((offer) {
          return GestureDetector(
            onTap: () {
              context.read<OfferBloc>().add(SelectOffer(offer));
              // Return the selected offer immediately when tapped
              Navigator.pop(context, offer);
            },
            child: OfferCard(offer: offer),
          );
        }).toList(),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
