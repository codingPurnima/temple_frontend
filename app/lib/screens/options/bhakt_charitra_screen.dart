import 'dart:async';
import 'package:app/core/app_theme.dart';
import 'package:app/helper/session.dart';
import 'package:app/screens/details/bhakt_detail_screen.dart';
import 'package:app/widgets/state_widgets/app_empty.dart';
import 'package:app/widgets/state_widgets/app_error.dart';
import 'package:app/widgets/state_widgets/app_loading.dart';
import 'package:app/widgets/state_widgets/app_search.dart';
import 'package:flutter/material.dart';
import '../../services/character_service.dart';

class BhaktCharitraScreen extends StatefulWidget {
  const BhaktCharitraScreen({super.key});

  @override
  State<BhaktCharitraScreen> createState() => _BhaktCharitraScreenState();
}

class _BhaktCharitraScreenState extends State<BhaktCharitraScreen> {
  final CharacterService _service = CharacterService();

  bool isLoading = true;
  List characters = [];
  bool hasError = false;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      loadCharacters(search: value);
    });
  }

  @override
  void initState() {
    super.initState();
    loadCharacters();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadCharacters({String? search}) async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      final result = await _service.getCharacters(search: search);

      if (!mounted) return;
      setState(() {
        characters = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load data. Try refreshing.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchmentBackground,
      appBar: AppBar(title: const Text("भक्त चरित्र")),
      body: Column(
        children: [
          AppSearchBar(
            controller: _searchController,
            hintText: "भक्त का नाम खोजें...",
            onChanged: _onSearchChanged,
            onClear: () => loadCharacters(),
            onSearch: () => loadCharacters(search: _searchController.text),
          ),
          Expanded(
            child: isLoading
                ? const AppLoadingView(message: "चरित्र लोड हो रहे हैं...")
                : hasError
                ? RefreshIndicator(
                    onRefresh: () =>
                        loadCharacters(search: _searchController.text),
                    child: AppErrorView(
                      onRetry: () =>
                          loadCharacters(search: _searchController.text),
                    ),
                  )
                : characters.isEmpty
                ? RefreshIndicator(
                    onRefresh: () => loadCharacters(),
                    child: const AppEmptyView(
                      icon: Icons.auto_stories_outlined,
                      title: "कोई भक्त चरित्र नहीं मिला",
                      subtitle: "अन्य नाम से खोजें अथवा पृष्ठ को रिफ्रेश करें",
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => loadCharacters(),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      itemCount: characters.length,
                      itemBuilder: (context, index) {
                        final char = characters[index];
                        final name = char["name"] ?? "";
                        final initial = name.isNotEmpty
                            ? name.substring(0, 1)
                            : "भ";

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
                              alignment: Alignment.center,
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  fontFamily: 'TiroDevanagariHindi',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppTheme.saffronAccent,
                                ),
                              ),
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(
                                fontFamily: 'TiroDevanagariHindi',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
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
                                        builder: (_) => AlertDialog(
                                          title: const Text("चरित्र हटाएं"),
                                          content: Text(
                                            "क्या आप सचमुच '$name' चरित्र हटाना चाहते हैं?",
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
                                            .deleteCharacter(char["id"]);

                                        if (!mounted) return;
                                        if (success) {
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text("Deleted"),
                                            ),
                                          );
                                          loadCharacters();
                                        } else {
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text("Failed"),
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
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BhaktDetailScreen(
                                    characterId: char["id"],
                                  ),
                                ),
                              );

                              if (result == true) {
                                loadCharacters(search: _searchController.text);
                              }
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
