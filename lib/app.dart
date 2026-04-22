import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/router.dart';
import 'features/boot/bloc/boot_bloc.dart';
import 'core/kernel/event_bus.dart';

class PocketOSApp extends StatefulWidget {
  const PocketOSApp({super.key});

  @override
  State<PocketOSApp> createState() => _PocketOSAppState();
}

class _PocketOSAppState extends State<PocketOSApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    SystemEventBus.instance.stream.listen((event) {
      if (event is NavigationEvent) {
        _navigatorKey.currentState?.pushNamed(event.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BootBloc>(create: (_) => BootBloc()),
      ],
      child: MaterialApp(
        title: 'PocketOS',
        theme: AppTheme.darkTheme,
        navigatorKey: _navigatorKey,
        initialRoute: AppRouter.kBootRoute,
        onGenerateRoute: AppRouter.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
