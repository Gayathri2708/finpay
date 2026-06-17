// Handles deep links (finpay://...) using app_links package and routes to the correct screen.
import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  GoRouter? _router;
  StreamSubscription<Uri>? _subscription;

  void setRouter(GoRouter router) => _router = router;

  Future<void> initialize() async {
    // Handle the link that opened the app from terminated state
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }

    // Listen for links while the app is running
    _subscription = _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri uri) {
    if (_router == null) return;

    // finpay://transaction/{id}
    if (uri.host == 'transaction' && uri.pathSegments.isNotEmpty) {
      _router!.push('/transaction/${uri.pathSegments.first}');
      return;
    }

    // finpay://send/{phone}
    if (uri.host == 'send' && uri.pathSegments.isNotEmpty) {
      _router!.push('/send-money?phone=${uri.pathSegments.first}');
      return;
    }

    // finpay://home
    if (uri.host == 'home') {
      _router!.go('/home');
      return;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
