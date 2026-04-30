import 'package:app/services/lyrics_service.dart';
import 'package:flutter/material.dart';


class PadScreen extends StatefulWidget {
  final int lyricId;

  const PadScreen({super.key, required this.lyricId});

  @override
  State<PadScreen> createState() => _PadScreenState();
}

class _PadScreenState extends State<PadScreen> {
  final LyricsService _service = LyricsService();
  bool isLoading = true;
  Map<String, dynamic>? lyric;

  @override
  void initState() {
    super.initState();
    loadLyric();
  }

  Future<void> loadLyric() async {
    final result = await _service.getLyricById(widget.lyricId);

    setState(() {
        lyric = result;
        isLoading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: FittedBox(fit: BoxFit.scaleDown,child: Text(lyric?["title"] ?? ""))),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : lyric == null
          ? const Center(child: Text("Failed to load"))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Text(
                  lyric!["content"] ?? "",
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 16, height: 1.9),
                ),
              ),
            ),
    );
  }
}
