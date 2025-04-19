part of 'offer_bloc.dart'; // Link to the main library

abstract class OfferState {}

class OfferLoading extends OfferState {}

class OfferLoaded extends OfferState {
  final List<Offer> offers;
  final Offer? selectedOffer;

  OfferLoaded(this.offers, {this.selectedOffer});

  OfferLoaded copyWith({List<Offer>? offers, Offer? selectedOffer}) {
    return OfferLoaded(
      offers ?? this.offers,
      selectedOffer: selectedOffer ?? this.selectedOffer,
    );
  }
}

class OfferError extends OfferState {
  final String message;
  OfferError(this.message);
}