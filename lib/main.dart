import 'package:flutter/material.dart';

import 'data/caller_repository.dart';
import 'screens/caller_details_screen.dart';
import 'screens/home_screen.dart';
import 'services/call_event_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CallEventService.instance.initialize();
  runApp(const CallInfoApp());
}

class CallInfoApp extends StatefulWidget {
  const CallInfoApp({super.key});

  @override
  State<CallInfoApp> createState() => _CallInfoAppState();
}

class _CallInfoAppState extends State<CallInfoApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  final CallerRepository _repository = CallerRepository();

  @override
  void initState() {
    super.initState();
    CallEventService.instance.deepLinks.listen((phoneNumber) {
      _navigatorKey.currentState?.pushNamed(
        '/caller',
        arguments: phoneNumber,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Call Info',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/caller') ?? false) {
          final number = settings.arguments as String? ??
              Uri.parse(settings.name ?? '').queryParameters['number'];
          if (number == null || number.isEmpty) {
            return MaterialPageRoute(
              builder: (_) => HomeScreen(
                onOpenCallerDetails: _openCallerDetails,
              ),
            );
          }

          return MaterialPageRoute(
            builder: (_) => CallerDetailsScreen(
              phoneNumber: number,
              repository: _repository,
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            onOpenCallerDetails: _openCallerDetails,
          ),
        );
      },
    );
  }

  void _openCallerDetails(String phoneNumber) {
    _navigatorKey.currentState?.pushNamed(
      '/caller',
      arguments: phoneNumber,
    );
  }
}
