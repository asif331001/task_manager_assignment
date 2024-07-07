

import 'package:task_manager_assignment/models/loginModels/user_data.dart';
import 'package:task_manager_assignment/services/network_request.dart';
import 'package:task_manager_assignment/utils/app_strings.dart';

class UserInfoService {
  static late Object finalResponse;

  static Future<Object> updateUserProfile(
      String token, UserData userData) async {
    return await NetworkRequest().postRequest(
      uri: "${AppStrings.baseUrl}${AppStrings.profileUpdateEndpoint}",
      body: userData.toJson(),
      headers: {"content-type": "application/json", "token": token},
    );
  }
}
