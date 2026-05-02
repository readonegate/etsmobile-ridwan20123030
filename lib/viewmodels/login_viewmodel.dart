import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class LoginViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserModel? _user;
  UserModel? get user => _user;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    UserModel result = await _apiService.login(email, password);

    if (result.error != null) {
      _errorMessage = result.error;
      _user = null;
      _setLoading(false);
      return false;
    } else {
      _user = result;
      _errorMessage = null;
      _setLoading(false);
      
      // Simpan token ke local storage
      final prefs = await SharedPreferences.getInstance();
      if (result.token != null) {
        await prefs.setString('token', result.token!);
      }
      
      return true;
    }
  }

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token != null) {
      _user = UserModel(token: token);
      notifyListeners();
      return true;
    }
    return false;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    notifyListeners();
    
    // Hapus token dari local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
