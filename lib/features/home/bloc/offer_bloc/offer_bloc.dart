library offer_bloc;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/features/home/model/offer_model.dart';
import 'package:rent_cam/features/home/services/offer_service.dart';

part 'offer_event.dart'; 
part 'offer_state.dart'; 

class OfferBloc extends Bloc<OfferEvent, OfferState> {
  final OfferRepository _repository = OfferRepository();

  OfferBloc() : super(OfferLoading()) {
    on<FetchOffers>(_onFetchOffers);
    on<SelectOffer>(_onSelectOffer);
    on<CopyToClipboard>(_onCopyToClipboard);
  }

  void _onFetchOffers(FetchOffers event, Emitter<OfferState> emit) async {
    try {
      final offers = await _repository.getOffers();
      emit(OfferLoaded(offers, selectedOffer: offers.isNotEmpty ? offers.first : null));
    } catch (e) {
      emit(OfferError('Failed to load offers'));
    }
  }

  void _onSelectOffer(SelectOffer event, Emitter<OfferState> emit) {
    if (state is OfferLoaded) {
      final currentState = state as OfferLoaded;
      emit(currentState.copyWith(selectedOffer: event.offer));
    }
  }

  void _onCopyToClipboard(CopyToClipboard event, Emitter<OfferState> emit) {
  }
}