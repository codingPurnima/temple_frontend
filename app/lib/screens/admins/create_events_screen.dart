import 'package:app/core/app_theme.dart';
import 'package:app/core/constants.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateEventsScreen extends StatefulWidget {
  const CreateEventsScreen({super.key});

  @override
  State<CreateEventsScreen> createState() => _CreateEventsScreenState();
}

class _CreateEventsScreenState extends State<CreateEventsScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final capacityController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  final ApiClient _apiClient = ApiClient();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    capacityController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    final response = await _apiClient.postRequest("$baseUrl/events/create", {
      "title": titleController.text.trim(),
      "description": descController.text.trim().isEmpty
          ? null
          : descController.text.trim(),
      "capacity": capacityController.text.trim().isEmpty
          ? null
          : int.parse(capacityController.text.trim()),
      "start_date": DateFormat('yyyy-MM-dd').format(selectedStartDate!),
      "end_date": DateFormat('yyyy-MM-dd').format(selectedEndDate!),
    });

    if (!mounted) return;
    setState(() => isLoading = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Event added successfully!"),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to create event. Please try again."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchmentBackground,
      appBar: AppBar(
        title: const Text("उत्सव जोड़ें / Create Event"),
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
                      "उत्सव / कार्यक्रम विवरण",
                      style: TextStyle(
                        fontFamily: 'TiroDevanagariHindi',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "उत्सव का नाम, तिथि व अन्य विवरण भरें",
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
                        labelText: "उत्सव का शीर्षक * (Title)",
                        hintText: "उदा. श्री राम नवमी महोत्सव",
                        prefixIcon: Icon(
                          Icons.celebration_outlined,
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
                      controller: descController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: "विवरण (Description)",
                        hintText: "उत्सव का संक्षिप्त विवरण...",
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: capacityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "क्षमता (Capacity - वैकल्पिक)",
                        hintText: "उदा. 100",
                        prefixIcon: Icon(
                          Icons.people_outline_rounded,
                          color: AppTheme.saffronAccent,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: startDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "प्रारम्भ तिथि * (Start Date)",
                        hintText: "dd-mm-yyyy",
                        prefixIcon: Icon(
                          Icons.calendar_today_rounded,
                          color: AppTheme.saffronAccent,
                          size: 20,
                        ),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedStartDate = pickedDate;
                            startDateController.text = DateFormat(
                              'dd-MM-yyyy',
                            ).format(selectedStartDate!);
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Start Date is required";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: endDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "समापन तिथि * (End Date)",
                        hintText: "dd-mm-yyyy",
                        prefixIcon: Icon(
                          Icons.event_rounded,
                          color: AppTheme.saffronAccent,
                          size: 20,
                        ),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedStartDate ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedEndDate = pickedDate;
                            endDateController.text = DateFormat(
                              'dd-MM-yyyy',
                            ).format(selectedEndDate!);
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "End Date is required";
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
                                "उत्सव सहेजें / Submit",
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
