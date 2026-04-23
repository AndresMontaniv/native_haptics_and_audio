import 'package:flutter/material.dart';
import 'package:native_haptics_and_audio/native_haptics_and_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _repo = NativeHapticsAndAudioRepository.instance;
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _repo.initialize();
    if (!mounted) return;
    setState(() {
      _ready = _repo.isInitialized;
      _error = _ready ? null : 'Initialization failed — check logs.';
    });
  }

  @override
  void dispose() {
    _repo.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Haptics & Audio Demo')),
        body: _ready
            ? _buildButtons()
            : Center(
                child: _error != null ? Text(_error!, style: const TextStyle(color: Colors.red)) : const CircularProgressIndicator(),
              ),
      ),
    );
  }

  Widget _buildButtons() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Sounds', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _soundButton('Scanner Beep', PosSound.scannerBeep),
        _soundButton('Warning Beep', PosSound.warningBeep),
        _soundButton('Double Warning', PosSound.doubleWarningBeep),
        _soundButton('Ka-Ching', PosSound.kaching),
        const SizedBox(height: 32),
        const Text('Haptics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _hapticButton('Success', PosHaptic.success),
        _hapticButton('Warning', PosHaptic.warning),
        _hapticButton('Error', PosHaptic.error),
      ],
    );
  }

  Widget _soundButton(String label, PosSound sound) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FilledButton.icon(onPressed: () => _repo.playSound(sound), icon: const Icon(Icons.volume_up), label: Text(label)),
    );
  }

  Widget _hapticButton(String label, PosHaptic haptic) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FilledButton.tonalIcon(onPressed: () => _repo.playHaptic(haptic), icon: const Icon(Icons.vibration), label: Text(label)),
    );
  }
}
