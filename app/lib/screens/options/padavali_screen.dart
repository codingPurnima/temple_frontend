import 'package:app/screens/details/pad_screen.dart';
import 'package:flutter/material.dart';
import '../../services/lyrics_service.dart';

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

  @override
  void initState() {
    super.initState();
    loadLyrics();
  }

  Future<void> loadLyrics({String? search}) async {
    setState(() => isLoading = true);

    final result = await _service.getLyrics(search: search);
    print("API result: $result");

    setState(() {
      lyrics = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("पदावली")),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
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

          // 📄 LIST
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
