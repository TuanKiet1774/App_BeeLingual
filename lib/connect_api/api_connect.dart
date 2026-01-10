import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../component/profileProvider.dart';
import '../controller/vocabController.dart';
import '../controller/authController.dart';
import '../model/topic.dart';
import '../model/vocabulary.dart';
import '../model/dictionary.dart';
import 'url.dart';

Future<Map<String, dynamic>?> fetchUserProfile(BuildContext context) async {
  final url = Uri.parse('$urlAPI/api/profile');
  final session = SessionManager();

  try {
    String? token = await session.getAccessToken();

    var res = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("Profile Status Code: ${res.statusCode}");
    print("Profile Body: ${res.body}");
    if (res.statusCode == 401) {
      print("Token hết hạn, đang thử refresh...");
      bool refreshed = await session.refreshAccessToken();
      if (refreshed) {
        token = await session.getAccessToken();
        res = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        print("Retry Profile Status: ${res.statusCode}");
        print("Retry Profile Body: ${res.body}");
      } else {
        session.logout(context);
        return null;
      }
    }

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      print("Lỗi API: Server trả về code ${res.statusCode}");
    }
  } catch (e) {
    print("Lỗi Exception lấy User Profile: $e");
  }
  return null;
}

Future<List<Topic>> fetchTopics([BuildContext? context]) async {
  final url = Uri.parse('$urlAPI/api/topics');
  final session = SessionManager();
  try {
    String? token = await session.getAccessToken();

    var res = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      print("Token hết hạn (401). Đang thử gia hạn...");
      final refreshSuccess = await session.refreshAccessToken();

      if (refreshSuccess) {
        token = await session.getAccessToken();
        res = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } else {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Phiên đăng nhập hết hạn")),
          );
          session.logout(context);
        }
        return [];
      }
    }

    // Xử lý kết quả (200 OK)
    if (res.statusCode == 200) {
      final dynamic decoded = json.decode(res.body);

      List<dynamic> listJson;
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('data')) {
          listJson = decoded['data'];
        } else {
          print("API trả về Map nhưng không có key 'data'");
          return [];
        }
      } else if (decoded is List) {
        listJson = decoded;
      } else {
        print("API trả về kiểu dữ liệu không xác định: ${decoded.runtimeType}");
        return [];
      }

      return listJson.map((e) => Topic.fromJson(e)).toList();
    } else {
      print("Lỗi lấy data: ${res.statusCode} - ${res.body}");
      return [];
    }
  } catch (e) {
    print("Error fetchTopics: $e");
    return [];
  }
}

Future<Map<String, dynamic>> fetchTopicsPaginated({
  required int page,
  required int limit,
  BuildContext? context,
}) async {
  final url = Uri.parse('$urlAPI/api/topics?page=$page&limit=$limit');
  final session = SessionManager();

  try {
    String? token = await session.getAccessToken();

    var res = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      print("Token hết hạn (401). Đang thử gia hạn...");
      final refreshSuccess = await session.refreshAccessToken();

      if (refreshSuccess) {
        token = await session.getAccessToken();
        res = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } else {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Phiên đăng nhập hết hạn")),
          );
          session.logout(context);
        }
        return {'total': 0, 'page': page, 'limit': limit, 'totalPages': 0, 'data': []};
      }
    }

    // Xử lý kết quả (200 OK)
    if (res.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(res.body);

      // API trả về: { total, page, limit, totalPages, data: [...] }
      final List<dynamic> topicsJson = decoded['data'] ?? [];
      final List<Topic> topics = topicsJson.map((e) => Topic.fromJson(e)).toList();

      return {
        'total': decoded['total'] ?? 0,
        'page': decoded['page'] ?? page,
        'limit': decoded['limit'] ?? limit,
        'totalPages': decoded['totalPages'] ?? 0,
        'data': topics,
      };
    } else {
      print("Lỗi lấy data: ${res.statusCode} - ${res.body}");
      return {'total': 0, 'page': page, 'limit': limit, 'totalPages': 0, 'data': []};
    }
  } catch (e) {
    print("Error fetchTopicsPaginated: $e");
    return {'total': 0, 'page': page, 'limit': limit, 'totalPages': 0, 'data': []};
  }
}

Future<List<Vocabulary>> fetchVocabulariesByTopic(String topicId, String level, [BuildContext? context]) async {
  final url = Uri.parse('$urlAPI/api/vocab?topic=$topicId&level=$level&limit=1000');

  final session = SessionManager();

  try {
    String? token = await session.getAccessToken();

    var res = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      print("Token hết hạn khi lấy từ vựng. Đang refresh...");
      final refreshSuccess = await session.refreshAccessToken();

      if (refreshSuccess) {
        token = await session.getAccessToken();
        res = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } else {
        if (context != null && context.mounted) {
          session.logout(context);
        }
        return [];
      }
    }

    if (res.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(res.body);
      final List<dynamic> listData = jsonResponse['data'];

      return listData.map((item) => Vocabulary.fromJson(item)).toList();
    } else {
      print("Lỗi lấy vocab: ${res.statusCode} - ${res.body}");
      return [];
    }
  } catch (e) {
    print("Exception fetchVocabularies: $e");
    return [];
  }
}

Future<bool> addVocabularyToDictionary(String vocabularyId, BuildContext context) async {
  final url = Uri.parse('$urlAPI/api/user-vocabulary/add');
  final session = SessionManager();

  try {
    String? token = await session.getAccessToken();
    var res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'vocabularyId': vocabularyId}),
    );

    if (res.statusCode == 401) {
      bool refreshed = await session.refreshAccessToken();
      if (refreshed) {
        token = await session.getAccessToken();
        // Thử lại lần 2
        res = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'vocabularyId': vocabularyId}),
        );
      } else {
        if (context.mounted) session.logout(context);
        return false;
      }
    }

    if (res.statusCode == 200) {
      if (context.mounted) {
        Provider.of<UserVocabulary>(context, listen: false).reloadVocab(context);
      }

      return true;
    } else if (res.statusCode == 400) {
      final errorData = jsonDecode(res.body);
      print("Lỗi API (400): ${errorData['message']}");
    } else {
      print("Lỗi API: Server trả về code ${res.statusCode}");
    }
  } catch (e) {
    print("Lỗi Exception khi thêm từ điển: $e");
  }
  return false;
}

Future<List<UserVocabularyItem>> fetchUserDictionary([BuildContext? context]) async {
  final url = Uri.parse('$urlAPI/api/user-vocabulary');
  final session = SessionManager();

  try {
    String? token = await session.getAccessToken();
    var res = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      final refreshSuccess = await session.refreshAccessToken();
      if (refreshSuccess) {
        token = await session.getAccessToken();
        res = await http.get(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'});
      } else {
        if (context != null && context.mounted) session.logout(context);
        return [];
      }
    }

    if (res.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(res.body);
      final List<dynamic> listData = jsonResponse['data'];

      return listData.map((item) => UserVocabularyItem.fromJson(item)).toList();
    } else {
      print("Lỗi lấy từ điển cá nhân: ${res.statusCode} - ${res.body}");
      return [];
    }
  } catch (e) {
    print("Exception fetchUserDictionary: $e");
    return [];
  }
}

Future<bool> deleteVocabularyFromDictionary(String userVocabId, BuildContext context) async {
  final url = Uri.parse('$urlAPI/api/user-vocabulary/$userVocabId');
  final session = SessionManager();

  try {
    String? token = await session.getAccessToken();

    var res = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      bool refreshed = await session.refreshAccessToken();
      if (refreshed) {
        token = await session.getAccessToken();
        res = await http.delete(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'});
      } else {
        session.logout(context);
        return false;
      }
    }

    if (res.statusCode == 200) {
      return true; // Xóa thành công
    } else {
      print("Lỗi API khi xóa: ${res.statusCode} - ${res.body}");
      return false;
    }
  } catch (e) {
    print("Lỗi Exception khi xóa từ điển: $e");
    return false;
  }
}

Future<bool> updateUserInfo({
  required String fullName,
  required String email,
  required String level,
  required BuildContext context,
}) async {
  final url = Uri.parse('$urlAPI/api/profile');
  final session = SessionManager();

  try {
    String? token = await session.getAccessToken();
    var res = await http.put( // Hoặc PATCH
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'fullname': fullName,
        'email': email,
        'level': level,
      }),
    );

    if (res.statusCode == 401) {
      final refreshSuccess = await session.refreshAccessToken();
      if (refreshSuccess) {
        token = await session.getAccessToken();
        res = await http.put(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}, body: jsonEncode({'fullname': fullName, 'email': email, 'level': level}));
      } else {
        session.logout(context);
        return false;
      }
    }
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật thông tin thành công!")));
      if (context.mounted) {
        Provider.of<UserProfileProvider>(context, listen: false).updateFullname(fullName);
      }

      return true;
    } else {
      return false;
    }
  } catch (e) {
    print("Lỗi Exception khi cập nhật: $e");
    return false;
  }
}

Future<Map<String, dynamic>> changePasswordAPI(String currentPassword, String newPassword, BuildContext context) async {
  final url = Uri.parse('$urlAPI/api/change-password');
  final session = SessionManager();
  try {
    String? token = await session.getAccessToken();
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'message': data['message'] ?? 'Đổi mật khẩu thành công'};
    } else if (response.statusCode == 401) {
      return {'success': false, 'message': 'Phiên đăng nhập hết hạn'};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Lỗi không xác định'};
    }
  } catch (e) {
    print("Lỗi đổi mật khẩu: $e");
    return {'success': false, 'message': 'Lỗi kết nối máy chủ'};
  }
}