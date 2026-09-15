import 'package:app/core/app_theme.dart';
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
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.character["name"]?.toString() ?? "");
    descriptionController = TextEditingController(
      text: widget.character["description"]?.toString() ?? "",
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    final success = await _service.updateCharacter(widget.character["id"], {
      "name": nameController.text.trim(),
      "description": descriptionController.text.trim(),
    });

    if (!mounted) return;
    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("चरित्र सफलतापूर्वक अद्यतित हुआ / Updated successfully!"),
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
        title: const Text("चरित्र सम्पादन / Edit Devotee"),
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
                      "चरित्र सम्पादन",
                      style: TextStyle(
                        fontFamily: 'TiroDevanagariHindi',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "विवरण में आवश्यक सुधार कर सहेजें",
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
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "भक्त का नाम * (Name)",
                        hintText: "उदा. श्री तुलसीदास जी",
                        prefixIcon: Icon(
                          Icons.person_outline_rounded,
                          color: AppTheme.saffronAccent,
                          size: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Name is required";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: descriptionController,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        labelText: "चरित्र विवरण * (Description)",
                        hintText: "यहाँ चरित्र का विस्तृत विवरण लिखें...",
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Description is required";
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
