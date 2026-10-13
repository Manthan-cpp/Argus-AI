import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Robust image widget that safely handles data URLs (base64 memory),
/// network URLs (http/https), blob URLs, and null/empty fallbacks
/// without crashing Flutter Web's image cache.
class SafeImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext context)? errorBuilder;

  const SafeImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
  });

  // Static in-memory cache to prevent re-decoding identical base64 frames on every build
  static final Map<String, Uint8List> _base64Cache = {};

  @override
  Widget build(BuildContext context) {
    final src = url?.trim();
    if (src == null || src.isEmpty) {
      return errorBuilder?.call(context) ?? _buildDefaultFallback();
    }

    // 1. Data URI (e.g. data:image/jpeg;base64,...)
    if (src.startsWith('data:image/')) {
      try {
        Uint8List? bytes = _base64Cache[src];
        if (bytes == null) {
          final commaIdx = src.indexOf(',');
          final base64Payload = commaIdx >= 0 ? src.substring(commaIdx + 1).trim() : src;
          bytes = base64Decode(base64Payload);
          if (_base64Cache.length > 50) {
            _base64Cache.remove(_base64Cache.keys.first);
          }
          _base64Cache[src] = bytes;
        }
        return Image.memory(
          bytes,
          key: ValueKey(src),
          gaplessPlayback: true,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (ctx, err, st) => errorBuilder?.call(ctx) ?? _buildDefaultFallback(),
        );
      } catch (_) {
        return errorBuilder?.call(context) ?? _buildDefaultFallback();
      }
    }

    // 2. Pure base64 string without data: header (if >= 64 chars and looks like base64)
    if (!src.startsWith('http') && !src.startsWith('blob:') && src.length > 80 && !src.contains(' ')) {
      try {
        Uint8List? bytes = _base64Cache[src];
        if (bytes == null) {
          bytes = base64Decode(src);
          if (_base64Cache.length > 50) {
            _base64Cache.remove(_base64Cache.keys.first);
          }
          _base64Cache[src] = bytes;
        }
        return Image.memory(
          bytes,
          key: ValueKey(src),
          gaplessPlayback: true,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (ctx, err, st) => errorBuilder?.call(ctx) ?? _buildDefaultFallback(),
        );
      } catch (_) {
        // Fall through to network
      }
    }

    // 3. Remote URL or Blob URL
    return Image.network(
      src,
      key: ValueKey(src),
      gaplessPlayback: true,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (ctx, err, st) => errorBuilder?.call(ctx) ?? _buildDefaultFallback(),
    );
  }

  Widget _buildDefaultFallback() {
    return Container(
      width: width,
      height: height,
      color: Colors.black26,
      child: const Center(
        child: Icon(Icons.movie_outlined, size: 28, color: Colors.white24),
      ),
    );
  }
}
