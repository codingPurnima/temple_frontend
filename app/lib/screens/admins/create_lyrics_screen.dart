import 'package:app/core/app_theme.dart';
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

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    authorController.dispose();
    super.dispose();
  }

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
      "author": authorController.text.trim().isEmpty
          ? ""
          : authorController.text.trim(),
    });

    if (!mounted) return;
    setState(() => isLoading = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("पद सफलतापूर्वक जोड़ा गया ।"),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      titleController.clear();
      contentController.clear();
      authorController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("प्रयास असफल । पुनः प्रयास करें ।"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchmentBackground,
      appBar: AppBar(
        title: const Text("नया पद जोड़ें / Add Lyrics"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.cardBorder),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "भजन / पद विवरण",
                      style: TextStyle(
                        fontFamily: 'TiroDevanagariHindi',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "पद का शीर्षक, सम्पूर्ण पंक्तियाँ एवं रचयिता का नाम अंकित करें",
                      style: TextStyle(
                        fontFamily: 'TiroDevanagariHindi',
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Divider(color: AppTheme.cardBorder, height: 1),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "पद का शीर्षक * (Title)",
                        hintText: "उदा. पायो जी मैंने राम रतन धन पायो",
                        prefixIcon: Icon(
                          Icons.music_note_rounded,
                          color: AppTheme.saffronAccent,
                          size: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Title is required";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: authorController,
                      decoration: const InputDecoration(
                        labelText: "रचयिता (Author - वैकल्पिक)",
                        hintText: "उदा. मीराबाई",
                        prefixIcon: Icon(
                          Icons.person_outline_rounded,
                          color: AppTheme.saffronAccent,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: contentController,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        labelText: "पद पंक्तियाँ * (Content)",
                        hintText: "यहाँ पद की समस्त पंक्तियाँ लिखें...",
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Content is required";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                "पद सहेजें / Submit",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
