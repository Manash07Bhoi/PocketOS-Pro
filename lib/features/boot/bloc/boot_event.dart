import 'package:equatable/equatable.dart';
sealed class BootEvent extends Equatable {
  const BootEvent();
  @override List<Object?> get props => [];
}
class StartBootSequence extends BootEvent {}
