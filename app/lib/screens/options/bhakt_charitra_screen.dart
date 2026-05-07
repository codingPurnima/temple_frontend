import 'dart:async';

import 'package:app/helper/session.dart';
import 'package:app/screens/details/bhakt_detail_screen.dart';
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
  bool hasError = true;

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

  Future<void> loadCharacters({String? search}) async {
    try {
      setState(() {
        isLoading = true;
        hasError = false; // reset error before loading
      });

      final result = await _service.getCharacters(search: search);

      setState(() {
        characters = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true; // 👈 important
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load data. Try refreshing.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("भक्त चरित्र")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    loadCharacters(search: _searchController.text);
                  },
                ),
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                ? RefreshIndicator(
                    onRefresh: () =>
                        loadCharacters(search: _searchController.text),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 150),
                        Center(child: Icon(Icons.error_outline, size: 50)),
                        SizedBox(height: 10),
                        Center(child: Text("Failed to load data")),
                        Center(child: Text("Pull down to refresh")),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => loadCharacters(),
                    child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: characters.length,
                      itemBuilder: (context, index) {
                        final char = characters[index];

                        return Card(
                          child: ListTile(
                            title: Text(char["name"] ?? ""),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 👑 DELETE button
                                if (Session.isAdmin)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text("Delete"),
                                          content: const Text(
                                            "Delete this character?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text("Cancel"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text("Delete"),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        final success = await _service
                                            .deleteCharacter(char["id"]);

                                        if (success) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("Deleted"),
                                            ),
                                          );
                                          loadCharacters();
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("Failed"),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BhaktDetailScreen(
                                    characterId: char["id"],
                                  ),
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
