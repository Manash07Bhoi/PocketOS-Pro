import 'package:equatable/equatable.dart';
sealed class BootState extends Equatable {
  const BootState();
  @override List<Object?> get props => [];
}
class BootInitial extends BootState {}
class BootInProgress extends BootState {
  final List<String> lines;
  const BootInProgress(this.lines);
  @override List<Object?> get props => [lines];
}
class BootComplete extends BootState {}
