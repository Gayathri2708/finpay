import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/deep_link/deep_link_service.dart';
import 'core/di/injection_container.dart' as di;
import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/send_money/presentation/bloc/send_money_bloc.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';
import 'features/wallet/presentation/bloc/wallet_bloc.dart';

late final NotificationService notificationService;
late final DeepLinkService deepLinkService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();

  notificationService = NotificationService(
    storage: di.sl(),
    apiClient: di.sl(),
  );
  await notificationService.initialize();

  deepLinkService = DeepLinkService();
  await deepLinkService.initialize();

  runApp(const FinPayApp());
}

class FinPayApp extends StatefulWidget {
  const FinPayApp({super.key});

  @override
  State<FinPayApp> createState() => _FinPayAppState();
}

class _FinPayAppState extends State<FinPayApp> with WidgetsBindingObserver {
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authBloc = di.sl<AuthBloc>()..add(CheckAuthRequested());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    deepLinkService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _authBloc.add(AppPaused());
      case AppLifecycleState.resumed:
        _authBloc.add(AppResumed());
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider(
          create: (_) => di.sl<WalletBloc>()..add(WalletLoadRequested()),
        ),
        BlocProvider(
          create: (_) =>
              di.sl<TransactionBloc>()..add(const TransactionsLoadRequested()),
        ),
        BlocProvider(
          create: (_) => di.sl<SendMoneyBloc>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final authBloc = context.read<AuthBloc>();
          final appRouter = AppRouter(authBloc: authBloc);

          notificationService.setRouter(appRouter.router);
          deepLinkService.setRouter(appRouter.router);

          return MaterialApp.router(
            title: 'FinPay',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}
