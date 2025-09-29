import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userName;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  // Mock authentication - in real app, this would call your API
  Future<bool> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 2));
    
    // Mock successful login
    if (email == 'admin@groceryflow.com' && password == 'admin123') {
      _isAuthenticated = true;
      _userEmail = email;
      _userName = 'Admin User';
      notifyListeners();
      return true;
    }
    
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userEmail = null;
    _userName = null;
    notifyListeners();
  }

  // Check if user is already authenticated (e.g., from stored token)
  Future<void> checkAuthStatus() async {
    // In real app, check stored token
    await Future.delayed(Duration(seconds: 1));
    
    // For demo, assume user is authenticated
    _isAuthenticated = true;
    _userEmail = 'admin@groceryflow.com';
    _userName = 'Admin User';
    notifyListeners();
  }
}
