import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Splitter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final audioContext = AudioContextConfig(
    focus: AudioContextConfigFocus.mixWithOthers,
  ).build();
  final AudioPlayer _leftPlayer = AudioPlayer();
  final AudioPlayer _rightPlayer = AudioPlayer();
  String? leftAudioPath;
  String? rightAudioPath;

  @override
  void initState() {
    super.initState();
    _leftPlayer.setReleaseMode(ReleaseMode.stop);
    _rightPlayer.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> _pickFile(String channel) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result != null) {
        setState(() {
          if (channel == 'left') {
            leftAudioPath = result.files.single.path;
          } else {
            rightAudioPath = result.files.single.path;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  Future<void> _play() async {
    if (leftAudioPath != null && rightAudioPath != null) {
      try {
        _leftPlayer.play(
          DeviceFileSource(leftAudioPath!),
          balance: -1.0,
          ctx: audioContext,
        );
        _rightPlayer.play(
          DeviceFileSource(rightAudioPath!),
          balance: 1.0,
          ctx: audioContext,
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error playing audio: $e')));
      }
    }
  }

  Future<void> _pause() async {
    try {
      await _leftPlayer.pause();
      await _rightPlayer.pause();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error pausing audio: $e')));
    }
  }

  Future<void> _stop() async {
    try {
      await _leftPlayer.stop();
      await _rightPlayer.stop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error stopping audio: $e')));
    }
  }

  @override
  void dispose() {
    _leftPlayer.dispose();
    _rightPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Splitter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _pickFile('left'),
              child: const Text('Select Left Audio'),
            ),
            Text(leftAudioPath ?? 'No file selected'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickFile('right'),
              child: const Text('Select Right Audio'),
            ),
            Text(rightAudioPath ?? 'No file selected'),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: _play,
                ),
                IconButton(icon: const Icon(Icons.pause), onPressed: _pause),
                IconButton(icon: const Icon(Icons.stop), onPressed: _stop),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
