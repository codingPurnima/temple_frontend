import 'package:app/core/constants.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';

class CreateCharacterScreen extends StatefulWidget {
  const CreateCharacterScreen({super.key});

  @override
  State<CreateCharacterScreen> createState() => _CreateCharacterScreenState();
}

class _CreateCharacterScreenState extends State<CreateCharacterScreen> {
  final nameController = TextEditingController();
  final descController = TextEditingController();

  final ApiClient _apiClient = ApiClient();

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

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


    final response = await _apiClient.postRequest("$baseUrl/characters/add", {
      "name": nameController.text.trim(),
      "description": descController.text.trim(),
    });

    setState(() => isLoading = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Bhakt Charitra added successfully!"),
        backgroundColor: Colors.green,
      ),
    );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add character. Please try again."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: FittedBox(fit: BoxFit.scaleDown, child: Text("Add character")),),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name*"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Name is required";
                    }
                    return null;
                  },
                ),
          
                const SizedBox(height: 5),

                TextFormField(
                  controller: descController,
                  maxLines: null,
                  decoration: const InputDecoration(labelText: "Description*"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Description is required";
                    }
                    return null;
                  },
                ),
          
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: isLoading ? null : submit,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Submit"),
                ),
              ],
            )
          ),
        ),
      ),
    );
  }
}
