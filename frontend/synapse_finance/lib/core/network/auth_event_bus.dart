import 'dart:async';

import 'package:injectable/injectable.dart';

/// Simple event bus that lets the [AuthInterceptor] signal session expiry
/// without creating a circular dependency on [AuthCubit].
@lazySingleton
class AuthEventBus {
  final _controller = StreamController<AuthEvent>.broadcast();

  Stream<AuthEvent> get stream => _controller.stream;

  void publish(AuthEvent event) => _controller.add(event);

  void dispose() => _controller.close();
}

enum AuthEvent { sessionExpired }
