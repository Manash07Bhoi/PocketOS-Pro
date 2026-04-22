import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'boot_event.dart';
import 'boot_state.dart';
import 'boot_step.dart';

class BootBloc extends Bloc<BootEvent, BootState> {
  final List<BootStep> _bootSteps = const [
    BootStep('Initializing PocketOS v1.0...', delayMs: 0),
    BootStep('Loading kernel modules...       [OK]', delayMs: 300),
    BootStep('Starting terminal engine...     [OK]', delayMs: 500),
    BootStep('Loading tool registry...        [OK]', delayMs: 400),
    BootStep('Mounting file system...         [OK]', delayMs: 350),
    BootStep('Requesting media permissions... [OK]', delayMs: 600),
    BootStep('Starting launcher...            [OK]', delayMs: 300),
    BootStep('', delayMs: 200),
    BootStep('PocketOS ready. Welcome, user.', delayMs: 500),
  ];

  BootBloc() : super(BootInitial()) {
    on<StartBootSequence>(_onStartBootSequence);
  }

  Future<void> _onStartBootSequence(StartBootSequence event, Emitter<BootState> emit) async {
    final List<String> currentLines = [];
    emit(BootInProgress(List.from(currentLines)));
    for (final step in _bootSteps) {
      if (step.delayMs > 0) {
        await Future.delayed(Duration(milliseconds: step.delayMs));
      }
      currentLines.add(step.text);
      emit(BootInProgress(List.from(currentLines)));
    }
    await Future.delayed(const Duration(milliseconds: 500));
    emit(BootComplete());
  }
}
