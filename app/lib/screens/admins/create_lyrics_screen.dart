import 'package:app/core/constants.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';

class CreateLyricsScreen extends StatefulWidget {
  const CreateLyricsScreen({super.key});

  @override
  State<CreateLyricsScreen> createState() => _CreateLyricsScreenState();
}

class _CreateLyricsScreenState extends State<CreateLyricsScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final authorController = TextEditingController();

  final ApiClient _apiClient = ApiClient();

  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  Future<void> submit() async {

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
        ),
      );
      return; 
    }

    setState(() => isLoading = true);

    final response = await _apiClient.postRequest("$baseUrl/lyrics/add", {
      "title": titleController.text.trim(),
      "content": contentController.text.trim(),
      "author": authorController.text.trim().isEmpty?"": authorController.text.trim(),
    });

    setState(() => isLoading = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Lyrics added successfully!"),
        backgroundColor: Colors.green,
      ),
    );
      titleController.clear();
      contentController.clear();
      authorController.clear();
      FocusScope.of(context).unfocus();
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to submit lyrics. Please try again."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Lyrics")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title *"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Title is required";
                    }
                    return null;
                  },
                ),
          
                const SizedBox(height: 5),
          
                TextFormField(
                  controller: contentController,
                  maxLines: null,
                  decoration: const InputDecoration(labelText: "Content *"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Title is required";
                    }
                    return null;
                  },
                ),
          
                const SizedBox(height: 5),
          
                TextFormField(
                  controller: authorController,
                  maxLines: 1,
                  decoration: const InputDecoration(labelText: "Author (optional)"),
                ),
          
                const SizedBox(height: 20),
          
                ElevatedButton(
                  onPressed: isLoading ? null : submit,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
