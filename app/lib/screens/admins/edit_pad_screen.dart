import 'package:app/core/app_theme.dart';
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
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController contentController;
  late TextEditingController authorController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.lyric["title"]?.toString() ?? "");
    contentController = TextEditingController(text: widget.lyric["content"]?.toString() ?? "");
    authorController = TextEditingController(text: widget.lyric["author"]?.toString() ?? "");
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    authorController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    final success = await _service.updateLyric(
      widget.lyric["id"],
      {
        "title": titleController.text.trim(),
        "content": contentController.text.trim(),
        "author": authorController.text.trim().isEmpty ? "" : authorController.text.trim(),
      },
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("पद सफलतापूर्वक अद्यतित हुआ / Updated successfully!"),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("सम्पादन विफल रहा। कृपया पुन: प्रयास करें।"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchmentBackground,
      appBar: AppBar(
        title: const Text("पद सम्पादन / Edit Lyrics"),
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
                      "भजन / पद सम्पादन",
                      style: TextStyle(
                        fontFamily: 'TiroDevanagariHindi',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "पद की पंक्तियों एवं विवरण में आवश्यक सुधार करें",
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
                        onPressed: isLoading ? null : save,
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
                                "परिवर्तन सहेजें / Save Changes",
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
