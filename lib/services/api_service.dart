import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user.dart';

class ApiService {
  final String baseUrl = 'your-beeceptor-api-key';

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> createUser(User user) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create user');
    }
  }

  Future<void> updateUser(String id, User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update user');
    }
  }

  Future<void> deleteUser(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user');
    }
  }
}
