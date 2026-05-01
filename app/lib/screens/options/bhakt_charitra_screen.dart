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

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCharacters();
  }

  Future<void> loadCharacters({String? search}) async {
    try {
      setState(() => isLoading = true);

      final result = await _service.getCharacters(search: search);

      setState(() {
        characters = result;
        isLoading = false;
      });
    } catch (e) {
      print("$e");
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
                : characters.isEmpty
                ? const Center(child: Text("No results found"))
                : RefreshIndicator(
                    onRefresh: () => loadCharacters(),
                    child: ListView.builder(
                      itemCount: characters.length,
                      itemBuilder: (context, index) {
                        final char = characters[index];

                        return Card(
                          child: ListTile(
                            title: Text(char["name"] ?? ""),
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
