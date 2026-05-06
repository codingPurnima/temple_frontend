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

  DateTime? selectedDate;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

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

    setState(() {
      isLoading = false;
    });

    print(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Event added successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create event. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(fit: BoxFit.scaleDown, child: Text("Create Event")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: "Description (optional)",
                  ),
                ),

                const SizedBox(height: 5),

                TextFormField(
                  controller: capacityController,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    labelText: "Capacity (optional)",
                  ),
                ),

                const SizedBox(height: 5),

                TextFormField(
                  controller: startDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Start Date*",
                    suffixIcon: Icon(Icons.calendar_today),
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
                      return "Date is required";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 5),

                TextFormField(
                  controller: endDateController,
                  decoration: const InputDecoration(
                    labelText: "End Date*",
                    suffixIcon: Icon(Icons.calendar_today),
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
                        selectedEndDate = pickedDate;
                        endDateController.text = DateFormat(
                          'dd-MM-yyyy',
                        ).format(selectedEndDate!);
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Date is required";
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
            ),
          ),
        ),
      ),
    );
  }
}
