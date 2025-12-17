part of 'arrivals_cubit.dart';

class ArrivalsState extends Equatable {
  const ArrivalsState._({required this.status, this.items = const [], this.error});

  const ArrivalsState.initial() : this._(status: ArrivalsStatus.initial);
  const ArrivalsState.loading() : this._(status: ArrivalsStatus.loading);
  const ArrivalsState.loaded(List<ArrivalSummary> items) : this._(status: ArrivalsStatus.loaded, items: items);
  const ArrivalsState.failure(String error) : this._(status: ArrivalsStatus.failure, error: error);

  final ArrivalsStatus status;
  final List<ArrivalSummary> items;
  final String? error;

  @override
  List<Object?> get props => [status, items, error];
}

enum ArrivalsStatus { initial, loading, loaded, failure }

