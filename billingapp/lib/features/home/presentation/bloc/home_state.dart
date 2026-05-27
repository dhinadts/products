import 'package:equatable/equatable.dart';

import '../../data/models/home_item.dart';

enum HomeStatus { initial, loading, success, error }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.items = const [],
    this.message,
  });

  final HomeStatus status;
  final List<HomeItem> items;
  final String? message;

  HomeState copyWith({
    HomeStatus? status,
    List<HomeItem>? items,
    String? message,
  }) {
    return HomeState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
