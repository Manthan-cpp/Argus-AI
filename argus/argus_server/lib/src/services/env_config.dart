import 'dart:io';

/// Automatic .env loader and configuration provider for Argus Server.
/// Reads `.env` from local, parent, or project root directories.
class EnvConfig {
  static final Map<String, String> _cache = {};
  static bool _loaded = false;

  /// Loads environment variables from the nearest `.env` file if not already loaded.
  static void load() {
    if (_loaded) return;
    _loaded = true;

    final candidatePaths = [
      '${Directory.current.path}/.env',
      '${Directory.current.path}/../.env',
      '${Directory.current.path}/../../.env',
      './.env',
      '../.env',
      '../../.env',
    ];

    for (final p in candidatePaths) {
      final file = File(p);
      if (file.existsSync()) {
        try {
          final lines = file.readAsLinesSync();
          for (final rawLine in lines) {
            final line = rawLine.trim();
            if (line.isEmpty || line.startsWith('#')) continue;
            final eqIdx = line.indexOf('=');
            if (eqIdx > 0) {
              final key = line.substring(0, eqIdx).trim();
              var val = line.substring(eqIdx + 1).trim();
              if ((val.startsWith('"') && val.endsWith('"')) ||
                  (val.startsWith("'") && val.endsWith("'"))) {
                val = val.substring(1, val.length - 1);
              }
              if (key.isNotEmpty && !_cache.containsKey(key)) {
                _cache[key] = val;
              }
            }
          }
          break; // Found and loaded the nearest .env file
        } catch (_) {
          // Ignore read error and try next candidate
        }
      }
    }
  }

  /// Get value by key, checking in-memory loaded .env first, then Platform.environment
  static String? get(String key) {
    if (!_loaded) load();
    final cached = _cache[key];
    if (cached != null && cached.isNotEmpty) return cached;
    try {
      final envVal = Platform.environment[key];
      if (envVal != null && envVal.isNotEmpty) return envVal;
    } catch (_) {}
    return null;
  }

  static String? get geminiApiKey => get('GEMINI_API_KEY');
  static String? get groqApiKey => get('GROQ_API_KEY');
  static bool get hasGeminiKey => geminiApiKey != null && geminiApiKey!.isNotEmpty;
  static bool get hasGroqKey => groqApiKey != null && groqApiKey!.isNotEmpty;
}
