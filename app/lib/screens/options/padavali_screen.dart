import 'dart:async';

import 'package:app/screens/details/pad_screen.dart';
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

  Future<void> loadLyrics({String? search}) async {
    try {
      setState(() => isLoading = true);

      final result = await _service.getLyrics(search: search);
      setState(() {
        lyrics = result;
        isLoading = false;
      });
    } catch (e) {
      print("$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("पदावली")),
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
                  icon: Icon(Icons.search),
                  onPressed: () {
                    loadLyrics(search: _searchController.text);
                  },
                ),
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : lyrics.isEmpty
                ? const Center(child: Text("No results found"))
                : RefreshIndicator(
                    onRefresh: () => loadLyrics(),
                    child: ListView.builder(
                      itemCount: lyrics.length,
                      itemBuilder: (context, index) {
                        final lyric = lyrics[index];

                        return Card(
                          child: ListTile(
                            title: Text(lyric["title"] ?? ""),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 👤 Author (for everyone)
                                Text(lyric["author"] ?? ""),
                                // 👑 DELETE button (admin only)
                                if (Session.isAdmin)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Delete"),
                                          content: const Text(
                                            "Are you sure you want to delete this?",
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
                                            .deleteLyric(lyric["id"]);
                                        if (success) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Deleted successfully",
                                              ),
                                            ),
                                          );
                                          loadLyrics();
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("Delete failed"),
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
