import 'package:app/helper/session.dart';
import 'package:app/screens/admins/edit_character_screen.dart';
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
      appBar: AppBar(title: FittedBox(fit: BoxFit.scaleDown, child: Text(character?["name"]??"")), actions: [
        if (Session.isAdmin)
      IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  EditCharacterScreen(character: character!),
            ),
          );

          if (result == true) {
            loadCharacter();
          }
        },
      ),
      ],),
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
                        Text(character!["description"] ?? ""),
                      ],
                    ),
                  ),
                ),
    );
  }
}