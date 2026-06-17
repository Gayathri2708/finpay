import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/send_money/presentation/bloc/send_money_bloc.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';
import 'features/wallet/presentation/bloc/wallet_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const FinPayApp());
}

class FinPayApp extends StatelessWidget {
  const FinPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>()..add(CheckAuthRequested()),
        ),
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
