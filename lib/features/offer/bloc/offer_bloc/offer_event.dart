part of 'offer_bloc.dart'; // Link to the main library

abstract class OfferEvent {}

class FetchOffers extends OfferEvent {}

class SelectOffer extends OfferEvent {
  final Offer offer;
  SelectOffer(this.offer);
}

class CopyToClipboard extends OfferEvent {
  final String code;
  CopyToClipboard(this.code);
}