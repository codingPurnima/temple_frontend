import 'package:app/services/character_service.dart';
import 'package:flutter/material.dart';

class EditCharacterScreen extends StatefulWidget {
  final Map<String, dynamic> character;
  const EditCharacterScreen({super.key, required this.character});

  @override
  State<EditCharacterScreen> createState() => _EditCharacterScreenState();
}

class _EditCharacterScreenState extends State<EditCharacterScreen> {
  final _service = CharacterService();

  late TextEditingController nameController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.character["name"]);
    descriptionController = TextEditingController(
      text: widget.character["description"],
    );
  }

  void save() async {
    final success = await _service.updateCharacter(widget.character["id"], {
      "name": nameController.text,
      "description": descriptionController.text,
    });

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Edit failed. Try again."),
          ),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: FittedBox(fit: BoxFit.scaleDown, child: const Text("Edit Character"))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController),
            Expanded(
              child: TextField(
                controller: descriptionController,
                maxLines: null,
              ),
            ),
            ElevatedButton(onPressed: save, child: const Text("Save")),
          ],
        ),
      ),
    );
  }
}
