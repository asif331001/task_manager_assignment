import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_assignment/models/loginModels/login_model.dart';
import 'package:task_manager_assignment/models/responseModel/success.dart';
import 'package:task_manager_assignment/services/auth_service.dart';
import 'package:task_manager_assignment/utils/app_navigation.dart';


import '../models/loginModels/user_data.dart';
import 'user_view_model.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isPasswordObscured = true;
  bool _isLoading = false;
  bool finalStatus = false;
  String _recoveryEmail = "";
  String _otp = "";
  late Object response;
  AuthService authService = AuthService();
  late SharedPreferences preferences;
  Map<String, String> resetPasswordInformation = {};

  bool get isPasswordObscure => _isPasswordObscured;

  bool get isLoading => _isLoading;

  String get recoveryEmail => _recoveryEmail;

  void setLoading(value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> registerUser(
      {required String email,
      required String firstName,
      required String lastName,
      required String mobileNumber,
      required String password}) async {
    finalStatus = false;
    setLoading(true);
    UserData userData = UserData(
      email: email,
      firstName: firstName,
      lastName: lastName,
      mobile: mobileNumber,
      password: password,
    );
    response = await authService.registration(userData);
    (response is Success) ? finalStatus = true : finalStatus = false;
    setLoading(false);
    return (finalStatus);
  }

  Future<bool> signInUser(
      {required String email,
      required String password,
      required UserViewModel userViewModel}) async {
    finalStatus = false;
    setLoading(true);
    response = await authService.signIn(email, password);
    if (response is Success) {
      LoginModel loginModel = LoginModel.fromJson(
          (response as Success).response as Map<String, dynamic>);
      finalStatus = true;
      preferences = await SharedPreferences.getInstance();
      userViewModel.saveUserData(loginModel, preferences, password);
    } else {
      finalStatus = false;
    }
    setLoading(false);
    return (finalStatus);
  }

  Future<bool> sendOTP(String email, {bool isResending = false}) async {
    finalStatus = false;
    if (!isResending) setLoading(true);
    response = await authService.requestOTP(email);
    if (response is Success) {
      Map<String, dynamic> status =
          (response as Success).response as Map<String, dynamic>;
      if (status['status'] == "success") {
        _recoveryEmail = email;
        finalStatus = true;
      }
    }
    if (!isResending) setLoading(false);
    return finalStatus;
  }

  Future<bool> verifyOTP(String otp) async {
    finalStatus = false;
    setLoading(true);
    response = await authService.verifyOTP(otp, _recoveryEmail);
    if (response is Success) {
      Map<String, dynamic> status =
          (response as Success).response as Map<String, dynamic>;
      if (status['status'] == "success") {
        _otp = otp;
        finalStatus = true;
      }
    }
    setLoading(false);
    return finalStatus;
  }

  Future<bool> resetPassword(String newPassword) async {
    finalStatus = false;
    setLoading(true);
    resetPasswordInformation.putIfAbsent("email", () => _recoveryEmail);
    resetPasswordInformation.putIfAbsent("OTP", () => _otp);
    resetPasswordInformation.putIfAbsent("password", () => newPassword);
    response = await authService.resetPassword(resetPasswordInformation);
    if (response is Success) {
      Map<String, dynamic> status =
          (response as Success).response as Map<String, dynamic>;
      if (status["status"] == "success") {
        resetPasswordInformation = {};
        finalStatus = true;
      }
    }
    setLoading(false);
    return finalStatus;
  }

  Future<bool> authenticateToken(String? token) async {
    if (token != null && !JwtDecoder.isExpired(token)) {
      return true;
    }
    return false;
  }

  Future<void> signOut() async {
    await AppNavigation().signOutUser();
  }

  set setPasswordObscure(bool value) {
    _isPasswordObscured = value;
    notifyListeners();
  }
}
