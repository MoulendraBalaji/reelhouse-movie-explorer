import 'package:flutter/foundation.dart';

class ImageUrlHelper {
  ImageUrlHelper._();

  /// Formats image URLs for Flutter Web to ensure CORS headers (Access-Control-Allow-Origin: *)
  /// and avoid referrer restrictions.
  static String format(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final trimmed = url.trim();

    if (kIsWeb) {
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        // If already proxied via wsrv.nl, return as-is
        if (trimmed.contains('wsrv.nl')) return trimmed;

        // Use wsrv.nl to proxy images with full CORS support on CanvasKit/HTML renderers
        return 'https://wsrv.nl/?url=${Uri.encodeComponent(trimmed)}';
      }
    }

    return trimmed;
  }
}

