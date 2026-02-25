import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final data = await ApiService.post(ApiConfig.login, {
      'email': email,
      'password': password,
    });

    // Save token
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['token']);

    return data;
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final data = await ApiService.post(ApiConfig.register, {
      'name': name,
      'email': email,
      'password': password,
    });

    // Save token
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['token']);

    return data;
  }

  static Future<User> getProfile() async {
    final data = await ApiService.get(ApiConfig.profile, auth: true);
    return User.fromJson(data);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }
}
