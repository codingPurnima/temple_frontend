import 'package:app/services/lyrics_service.dart';
import 'package:flutter/material.dart';

class EditPadScreen extends StatefulWidget {
  final Map<String, dynamic> lyric;
  const EditPadScreen({super.key, required this.lyric});

  @override
  State<EditPadScreen> createState() => _EditPadScreenState();
}

class _EditPadScreenState extends State<EditPadScreen> {
  final _service = LyricsService();

  late TextEditingController titleController;
  late TextEditingController contentController;
  late TextEditingController authorController;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.lyric["title"]);
    contentController = TextEditingController(text: widget.lyric["content"]);
    authorController = TextEditingController(text: widget.lyric["author"]);
  }

  void save() async{
    final success = await _service.updateLyric(
      widget.lyric["id"],
      {
        "title": titleController.text,
        "content": contentController.text,
        "author": authorController.text,
      },
    );

    if (success) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Pad")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleController),
            TextField(controller: authorController),
            Expanded(child: TextField(controller: contentController, maxLines: null)),
            ElevatedButton(onPressed: save, child: const Text("Save")),
          ],
        ),
      ),
    );
  }
}
