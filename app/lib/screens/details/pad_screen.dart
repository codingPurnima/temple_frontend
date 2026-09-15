import 'package:app/core/app_theme.dart';
import 'package:app/helper/session.dart';
import 'package:app/screens/admins/edit_pad_screen.dart';
import 'package:app/services/lyrics_service.dart';
import 'package:app/widgets/state_widgets/app_empty.dart';
import 'package:app/widgets/state_widgets/app_loading.dart';
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
    setState(() => isLoading = true);
    final result = await _service.getLyricById(widget.lyricId);

    if (!mounted) return;
    setState(() {
      lyric = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = lyric?["title"] ?? "";
    final author = lyric?["author"] ?? "";

    return Scaffold(
      backgroundColor: AppTheme.parchmentBackground,
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (Session.isAdmin && lyric != null)
            IconButton(
              tooltip: "Edit Pad",
              icon: const Icon(Icons.edit_outlined, size: 22),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditPadScreen(lyric: lyric!),
                  ),
                );
                if (result == true) {
                  await loadLyric();
                }
              },
            ),
        ],
      ),
      body: isLoading
          ? const AppLoadingView(message: "पद लोड हो रहा है...")
          : lyric == null
              ? const AppEmptyView(
                  icon: Icons.music_off_rounded,
                  title: "पद उपलब्ध नहीं है",
                  subtitle: "यह पद हटाया जा चुका है अथवा उपलब्ध नहीं है",
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 28,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.cardBorder,
                            width: 1.2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Traditional top verse header
                            const Icon(
                              Icons.music_note_rounded,
                              color: AppTheme.saffronAccent,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'TiroDevanagariHindi',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                            if (author.toString().trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.saffronLight,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.warmGoldLight,
                                  ),
                                ),
                                child: Text(
                                  "रचयिता: $author",
                                  style: const TextStyle(
                                    fontFamily: 'TiroDevanagariHindi',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.saffronAccent,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            const Divider(
                              color: AppTheme.cardBorder,
                              height: 1,
                            ),
                            const SizedBox(height: 22),

                            // Pad lyrics text
                            SelectableText(
                              (lyric!["content"] ?? "")
                                  .replaceAll('\\n', '\n'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'TiroDevanagariHindi',
                                fontSize: 17,
                                height: 2.1,
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "॥ इति ॥",
                              style: TextStyle(
                                fontFamily: 'TiroDevanagariHindi',
                                color: AppTheme.warmGold,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
