import 'dart:async';
import 'package:app/core/app_theme.dart';
import 'package:app/screens/details/pad_screen.dart';
import 'package:app/widgets/state_widgets/app_empty.dart';
import 'package:app/widgets/state_widgets/app_error.dart';
import 'package:app/widgets/state_widgets/app_loading.dart';
import 'package:app/widgets/state_widgets/app_search.dart';
import 'package:flutter/material.dart';
import '../../services/lyrics_service.dart';
import 'package:app/helper/session.dart';

class PadavaliScreen extends StatefulWidget {
  const PadavaliScreen({super.key});

  @override
  State<PadavaliScreen> createState() => _PadavaliScreenState();
}

class _PadavaliScreenState extends State<PadavaliScreen> {
  final LyricsService _service = LyricsService();

  bool isLoading = true;
  List lyrics = [];
  bool hasError = false;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      loadLyrics(search: value);
    });
  }

  @override
  void initState() {
    super.initState();
    loadLyrics();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadLyrics({String? search}) async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      final result = await _service.getLyrics(search: search);

      if (!mounted) return;
      setState(() {
        lyrics = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load data. Try refreshing")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchmentBackground,
      appBar: AppBar(title: const Text("पदावली")),
      body: Column(
        children: [
          AppSearchBar(
            controller: _searchController,
            hintText: "पद अथवा रचयिता खोजें...",
            onChanged: _onSearchChanged,
            onClear: () => loadLyrics(),
            onSearch: () => loadLyrics(search: _searchController.text),
          ),
          Expanded(
            child: isLoading
                ? const AppLoadingView(message: "पद लोड हो रहे हैं...")
                : hasError
                ? RefreshIndicator(
                    onRefresh: () => loadLyrics(search: _searchController.text),
                    child: AppErrorView(
                      onRetry: () => loadLyrics(search: _searchController.text),
                    ),
                  )
                : lyrics.isEmpty
                ? RefreshIndicator(
                    onRefresh: () => loadLyrics(),
                    child: const AppEmptyView(
                      icon: Icons.music_note_rounded,
                      title: "कोई पद नहीं मिला",
                      subtitle: "अन्य शब्द से खोजें अथवा पृष्ठ को रिफ्रेश करें",
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => loadLyrics(search: _searchController.text),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      itemCount: lyrics.length,
                      itemBuilder: (context, index) {
                        final lyric = lyrics[index];
                        final title = lyric["title"] ?? "";
                        final author = lyric["author"] ?? "";

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(
                              color: AppTheme.cardBorder,
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.saffronLight,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.warmGoldLight,
                                ),
                              ),
                              child: const Icon(
                                Icons.music_note_rounded,
                                color: AppTheme.saffronAccent,
                                size: 22,
                              ),
                            ),
                            title: Text(
                              title,
                              style: const TextStyle(
                                fontFamily: 'TiroDevanagariHindi',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            subtitle: author.toString().trim().isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      "रचयिता: $author",
                                      style: const TextStyle(
                                        fontFamily: 'TiroDevanagariHindi',
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  )
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (Session.isAdmin)
                                  IconButton(
                                    tooltip: "Delete",
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppTheme.errorRed,
                                      size: 22,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("पद हटाएं"),
                                          content: Text(
                                            "क्या आप सचमुच '$title' पद हटाना चाहते हैं?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text("रद्द करें"),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppTheme.errorRed,
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text("हटाएं"),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        final messenger = ScaffoldMessenger.of(
                                          context,
                                        );
                                        final success = await _service
                                            .deleteLyric(lyric["id"]);
                                        if (!mounted) return;
                                        if (success) {
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Deleted successfully",
                                              ),
                                            ),
                                          );
                                          loadLyrics();
                                        } else {
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text("Delete failed"),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppTheme.textMuted,
                                  size: 20,
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PadScreen(lyricId: lyric["id"]),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
