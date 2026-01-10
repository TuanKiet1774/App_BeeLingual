import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/user.dart';
import '../connect_api/url.dart';

class UserService {
  Future<List<User>> fetchUsers(String token) async {
    try {
      final url = Uri.parse('$urlAPI/users');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("Request to: $url");
      print("Status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> jsonResponse = json.decode(decodedBody);
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((item) => User.fromJson(item)).toList();
        } else {
          return [];
        }

      } else if (response.statusCode == 401) {
        throw Exception('Hết phiên đăng nhập (Unauthorized). Vui lòng login lại.');
      } else {
        // In body lỗi để debug
        print("Error Body: ${response.body}");
        throw Exception('Lỗi server: ${response.statusCode}');
      }

    } on SocketException {
      throw Exception('Không có kết nối Internet');
    } catch (e) {
      // 4. Rethrow để UI biết có lỗi mà hiện thông báo (Snackbar/Dialog)
      print("Exception in fetchUsers: $e");
      rethrow;
    }
  }
}