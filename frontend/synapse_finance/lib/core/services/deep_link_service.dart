import 'dart:async';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import 'home_widget_service.dart';

@lazySingleton
class DeepLinkService {
  static const MethodChannel _channel = MethodChannel('synapse_finance/widget');
  final HomeWidgetService _homeWidgetService;
  
  StreamController<String>? _linkStreamController;
  Stream<String>? _linkStream;

  DeepLinkService(this._homeWidgetService);

  Stream<String> get linkStream {
    _linkStreamController ??= StreamController<String>.broadcast();
    _linkStream ??= _linkStreamController!.stream;
    return _linkStream!;
  }

  Future<void> initialize() async {
    // Set up method call handler for deep links from native
    _channel.setMethodCallHandler(_handleMethodCall);
    
    // Check for initial link when app starts
    final initialLink = await getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }
    
    // Listen for deep link events
    linkStream.listen(_handleDeepLink);
  }

  Future<String?> getInitialLink() async {
    try {
      final String? link = await _channel.invokeMethod('getInitialLink');
      return link;
    } on PlatformException {
      return null;
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onDeepLink':
        final String link = call.arguments as String;
        _linkStreamController?.add(link);
        break;
    }
  }

  void _handleDeepLink(String link) {
    final uri = Uri.tryParse(link);
    if (uri == null) return;

    switch (uri.host) {
      case 'refresh':
        // Handle widget refresh request
        _homeWidgetService.updateNetWorthWidget();
        break;
      default:
        // Handle other deep links if needed
        break;
    }
  }

  void dispose() {
    _linkStreamController?.close();
  }
}