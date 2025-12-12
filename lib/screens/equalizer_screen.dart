import 'package:flutter/material.dart';
import '../equalizer_helper.dart';

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  double bassValue = 0.0;
  double trebleValue = 0.0;
  double vocalValue = 0.0;
  String selectedPreset = 'Normal';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await EqualizerHelper.getEqualizerSettings();
    setState(() {
      bassValue = settings['bass']!;
      trebleValue = settings['treble']!;
      vocalValue = settings['vocal']!;
    });
  }

  Future<void> _saveSettings() async {
    await EqualizerHelper.saveEqualizerSettings(bassValue, trebleValue, vocalValue);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Lưu cài đặt EQ thành công')),
      );
    }
  }

  Future<void> _applyPreset(String preset) async {
    await EqualizerHelper.applyPreset(preset);
    await _loadSettings();
    setState(() {
      selectedPreset = preset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎛 Equalizer'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================================
            // 🎚 Bass Control
            // ================================
            const Text(
              '🎚 Bass Boost',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Slider(
              value: bassValue,
              min: -20,
              max: 20,
              divisions: 40,
              label: '${bassValue.toStringAsFixed(1)}',
              onChanged: (value) {
                setState(() => bassValue = value);
              },
            ),
            const SizedBox(height: 20),

            // ================================
            // 🎺 Treble Control
            // ================================
            const Text(
              '🎺 Treble Boost',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Slider(
              value: trebleValue,
              min: -20,
              max: 20,
              divisions: 40,
              label: '${trebleValue.toStringAsFixed(1)}',
              onChanged: (value) {
                setState(() => trebleValue = value);
              },
            ),
            const SizedBox(height: 20),

            // ================================
            // 🗣 Vocal Boost
            // ================================
            const Text(
              '🗣 Vocal Boost',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Slider(
              value: vocalValue,
              min: -20,
              max: 20,
              divisions: 40,
              label: '${vocalValue.toStringAsFixed(1)}',
              onChanged: (value) {
                setState(() => vocalValue = value);
              },
            ),
            const SizedBox(height: 40),

            // ================================
            // 🔊 Presets
            // ================================
            const Text(
              '🔊 Preset',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                'Normal',
                'EDM',
                'Acoustic',
                'Bass Boost',
                'Treble Boost',
                'Vocal Boost'
              ]
                  .map((preset) => ElevatedButton(
                        onPressed: () => _applyPreset(preset),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedPreset == preset
                              ? Colors.deepPurple
                              : Colors.grey[300],
                          foregroundColor: selectedPreset == preset
                              ? Colors.white
                              : Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: Text(preset),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 40),

            // ================================
            // 💾 Save Button
            // ================================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('💾 Lưu cài đặt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ================================
            // 🔄 Reset Button
            // ================================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _applyPreset('Normal'),
                icon: const Icon(Icons.refresh),
                label: const Text('🔄 Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
