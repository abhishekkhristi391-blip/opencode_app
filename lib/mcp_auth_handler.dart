import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

class McpAuthHandler {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;
  String? _lastAuthUrl;

  String? get lastAuthUrl => _lastAuthUrl;

  Future<void> initialize() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        debugPrint('MCP Auth: initial deep link received: $initialLink');
      }
    } catch (e) {
      debugPrint('MCP Auth: failed to get initial link: $e');
    }
    _linkSub = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('MCP Auth: deep link received: $uri');
      },
      onError: (e) {
        debugPrint('MCP Auth: deep link stream error: $e');
      },
    );
  }

  void dispose() {
    _linkSub?.cancel();
  }
}

class McpAuthException implements Exception {
  final String message;
  final Uri? authUrl;

  McpAuthException(this.message, {this.authUrl});

  @override
  String toString() => message;
}
