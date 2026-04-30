import 'package:flutter/material.dart';
import '../../services/character_service.dart';

class BhaktDetailScreen extends StatefulWidget {
  final int characterId;

  const BhaktDetailScreen({super.key, required this.characterId});

  @override
  State<BhaktDetailScreen> createState() =>
      _BhaktDetailScreenState();
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
    final result =
        await _service.getCharacterById(widget.characterId);

    setState(() {
      character = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("चरित्र विवरण")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : character == null
              ? const Center(child: Text("Character not found"))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 350,
                          width: double.infinity,
                          child: Image.asset(
                            'assets/images/MeeraBaiSa.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          character!["name"] ?? "",
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Text(character!["description"] ?? ""),
                      ],
                    ),
                  ),
                ),
    );
  }
}