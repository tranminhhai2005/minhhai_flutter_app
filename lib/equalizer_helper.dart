import 'package:shared_preferences/shared_preferences.dart';

class EqualizerHelper {
  static const String _eqKey = 'equalizer_settings';

  /// Định nghĩa các preset
  static const Map<String, Map<String, double>> presets = {
    'Normal': {
      'bass': 0.0,
      'treble': 0.0,
      'vocal': 0.0,
    },
    'EDM': {
      'bass': 10.0,
      'treble': 5.0,
      'vocal': 2.0,
    },
    'Acoustic': {
      'bass': 2.0,
      'treble': 8.0,
      'vocal': 5.0,
    },
    'Bass Boost': {
      'bass': 15.0,
      'treble': 0.0,
      'vocal': 0.0,
    },
    'Treble Boost': {
      'bass': 0.0,
      'treble': 15.0,
      'vocal': 0.0,
    },
    'Vocal Boost': {
      'bass': 2.0,
      'treble': 2.0,
      'vocal': 15.0,
    },
  };

  /// Lưu cài đặt EQ
  static Future<void> saveEqualizerSettings(double bass, double treble, double vocal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('${_eqKey}_bass', bass);
    await prefs.setDouble('${_eqKey}_treble', treble);
    await prefs.setDouble('${_eqKey}_vocal', vocal);
  }

  /// Lấy cài đặt EQ
  static Future<Map<String, double>> getEqualizerSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'bass': prefs.getDouble('${_eqKey}_bass') ?? 0.0,
      'treble': prefs.getDouble('${_eqKey}_treble') ?? 0.0,
      'vocal': prefs.getDouble('${_eqKey}_vocal') ?? 0.0,
    };
  }

  /// Áp dụng preset
  static Future<void> applyPreset(String presetName) async {
    if (presets.containsKey(presetName)) {
      final preset = presets[presetName]!;
      await saveEqualizerSettings(preset['bass']!, preset['treble']!, preset['vocal']!);
    }
  }

  /// Reset về Normal
  static Future<void> resetToNormal() async {
    await applyPreset('Normal');
  }
}
