import 'package:app/services/api_service.dart';
import 'package:app/widgets/user_model.dart';
import 'package:flutter/material.dart';

class ManageUsersScreen extends StatefulWidget {
  final String token;

  const ManageUsersScreen({super.key, required this.token});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final data = await ApiClient.getUsers(widget.token);
      setState(() {
        users = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void promoteUser(User user) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Promote User"),
        content: Text("Make ${user.name} an ADMIN?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Yes"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiClient.makeAdmin(user.id, widget.token);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("User promoted")));
        fetchUsers(); // refresh
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to promote")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return isLoading
        ? Scaffold(
            appBar: AppBar(title: Text("")),
            body: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            appBar: AppBar(title: Text("All Users")),
            body: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(user.role),
                        SizedBox(width: 10),
                        if (user.role != "ADMIN")
                          ElevatedButton(
                            onPressed: () => promoteUser(user),
                            child: Text("Make Admin"),
                          ),
                      ],
                    ),
                  ),
                );
              },
          ),
          );
  }
}
