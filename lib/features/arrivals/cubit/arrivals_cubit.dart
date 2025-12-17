import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/arrivals_repository.dart';

part 'arrivals_state.dart';

class ArrivalsCubit extends Cubit<ArrivalsState> {
  ArrivalsCubit({required ArrivalsRepository repository})
      : _repo = repository,
        super(const ArrivalsState.initial());

  final ArrivalsRepository _repo;

  Future<void> load({String? q}) async {
    emit(const ArrivalsState.loading());
    try {
      final items = await _repo.pendingArrivals(q: q);
      emit(ArrivalsState.loaded(items));
    } catch (e) {
      emit(ArrivalsState.failure(e.toString()));
    }
  }
}

