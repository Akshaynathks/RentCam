import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/features/home/bloc/offer_bloc/offer_bloc.dart';
import 'package:rent_cam/features/home/model/offer_model.dart';

class OfferCard extends StatelessWidget {
  final Offer offer;

  const OfferCard({Key? key, required this.offer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: offer.imageUrl != null
                  ? Image.network(
                      offer.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image, size: 80),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Coupon Code:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    offer.couponCode,
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${offer.percentage}% OFF',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.green),
              onPressed: () {
                context.read<OfferBloc>().add(CopyToClipboard(offer.couponCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Copied: ${offer.couponCode}')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}