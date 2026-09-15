import 'package:app/core/app_theme.dart';
import 'package:app/helper/session.dart';
import 'package:app/screens/admins/edit_character_screen.dart';
import 'package:app/widgets/state_widgets/app_empty.dart';
import 'package:app/widgets/state_widgets/app_loading.dart';
import 'package:flutter/material.dart';
import '../../services/character_service.dart';

class BhaktDetailScreen extends StatefulWidget {
  final int characterId;

  const BhaktDetailScreen({super.key, required this.characterId});

  @override
  State<BhaktDetailScreen> createState() => _BhaktDetailScreenState();
}

class _BhaktDetailScreenState extends State<BhaktDetailScreen> {
  final CharacterService _service = CharacterService();

  bool isLoading = true;
  Map<String, dynamic>? character;

  @override
  void initState() {
    super.initState();
    loadCharacter();
  }

  Future<void> loadCharacter() async {
    setState(() => isLoading = true);
    final result = await _service.getCharacterById(widget.characterId);

    if (!mounted) return;
    setState(() {
      character = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = character?["name"] ?? "";
    final initial = name.isNotEmpty ? name.substring(0, 1) : "भ";

    return Scaffold(
      backgroundColor: AppTheme.parchmentBackground,
      appBar: AppBar(
        title: Text(name),
        actions: [
          if (Session.isAdmin && character != null)
            IconButton(
              tooltip: "Edit Character",
              icon: const Icon(Icons.edit_outlined, size: 22),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditCharacterScreen(character: character!),
                  ),
                );

                if (result == true) {
                  await loadCharacter();
                }
              },
            ),
        ],
      ),
      body: isLoading
          ? const AppLoadingView(message: "चरित्र लोड हो रहा है...")
          : character == null
              ? const AppEmptyView(
                  title: "चरित्र उपलब्ध नहीं है",
                  subtitle: "यह चरित्र हटाया जा चुका है अथवा उपलब्ध नहीं है",
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
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row with avatar and title
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
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
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.saffronAccent,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontFamily: 'TiroDevanagariHindi',
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        "भक्त चरित्र विवरण",
                                        style: TextStyle(
                                          fontFamily: 'TiroDevanagariHindi',
                                          fontSize: 13,
                                          color: AppTheme.saffronAccent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const Divider(
                              color: AppTheme.cardBorder,
                              height: 1,
                            ),
                            const SizedBox(height: 18),

                            // Description Text
                            Text(
                              character!["description"] ?? "",
                              style: const TextStyle(
                                fontFamily: 'TiroDevanagariHindi',
                                fontSize: 16.5,
                                height: 1.85,
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.justify,
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
