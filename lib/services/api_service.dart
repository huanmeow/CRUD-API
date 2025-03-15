import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:5000/api/accounts"; // Thay bằng URL API thực tế

  static Future<List<dynamic>> fetchAccounts() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Lỗi tải danh sách tài khoản");
    }
  }


  static Future<bool> addAccount(String username, String password, String game,
      int price) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "username": username,
        "password": password,
        "game": game,
        "price": price
      }),
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateAccount(int id, String username, String password,
      String game, int price) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "username": username,
        "password": password,
        "game": game,
        "price": price
      }),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteAccount(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));
    return response.statusCode == 200;
  }
}