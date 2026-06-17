import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/lock_screen_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/send_money/presentation/pages/send_money_page.dart';
import '../../features/transactions/presentation/pages/transaction_detail_page.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import '../../features/transactions/domain/entities/transaction_entity.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/register';
      final isLockRoute = location == '/lock';

      // Session expired — send to lock screen
      if (authState is SessionExpired && !isLockRoute) {
        return '/lock';
      }

      // Authenticated user on auth pages — send to home
      if (authState is Authenticated && isAuthRoute) {
        return '/home';
      }

      // Unauthenticated user on protected pages — send to login
      if (authState is Unauthenticated && !isAuthRoute) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/lock',
        name: 'lock',
        builder: (context, state) => const LockScreenPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/transactions',
        name: 'transactions',
        builder: (context, state) => const TransactionsPage(),
      ),
      GoRoute(
        path: '/transaction/:id',
        name: 'transaction-detail',
        builder: (context, state) {
          final transaction = state.extra as TransactionEntity;
          return TransactionDetailPage(transaction: transaction);
        },
      ),
      GoRoute(
        path: '/send-money',
        name: 'send-money',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'];
          return SendMoneyPage(initialPhone: phone);
        },
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) => notifyListeners());
  }
}
