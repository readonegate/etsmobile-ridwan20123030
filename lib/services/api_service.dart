import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.100:5000/api';

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      print(data);

      if (response.statusCode == 200) {
        return UserModel.fromJson(data);
      } else {
        return UserModel(error: data['error'] ?? 'Login failed');
      }
    } catch (e) {
      return UserModel(error: 'An error occurred: $e');
    }
  }
}
