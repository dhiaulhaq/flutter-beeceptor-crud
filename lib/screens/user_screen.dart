import 'package:flutter/material.dart';
import '../model/user.dart';
import '../services/api_service.dart';

class UserScreen extends StatefulWidget {
  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final ApiService apiService = ApiService();
  late Future<List<User>> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = apiService.fetchUsers();
  }

  void _refresh() {
    setState(() {
      futureUsers = apiService.fetchUsers();
    });
  }

  void _showForm({User? user}) {
    final nameController = TextEditingController(text: user?.name);
    final emailController = TextEditingController(text: user?.email);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(user == null ? 'Add User' : 'Edit User'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final newUser = User(
                    id: user?.id,
                    name: nameController.text,
                    email: emailController.text,
                  );
                  if (user == null) {
                    await apiService.createUser(newUser);
                  } else {
                    await apiService.updateUser(user.id!, newUser);
                  }
                  Navigator.of(context).pop();
                  _refresh();
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Delete User'),
            content: Text('Are you sure you want to delete this user?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await apiService.deleteUser(id);
                  Navigator.of(context).pop();
                  _refresh();
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Management')),
      body: FutureBuilder<List<User>>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final users = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (_, index) {
                  final user = users[index];
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showForm(user: user),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _confirmDelete(user.id!),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
