import 'dart:async';

sealed class SystemEvent {}
class NavigationEvent extends SystemEvent {
  final String path;
  NavigationEvent(this.path);
}

class SystemEventBus {
  static final SystemEventBus _instance = SystemEventBus._();
  static SystemEventBus get instance => _instance;
  SystemEventBus._();

  final _controller = StreamController<SystemEvent>.broadcast();
  Stream<SystemEvent> get stream => _controller.stream;

  void emit(SystemEvent event) => _controller.add(event);
  void dispose() => _controller.close();
}
