import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/post.dart';

/// Помилка, текст якої можна безпечно показати користувачу.
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const Duration _timeout = Duration(seconds: 10);

  /// GET /posts: повертає список заявок.
  Future<List<Post>> getPosts() {
    return _guard(() async {
      final response = await http
          .get(Uri.parse('$_baseUrl/posts'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Post.fromJson(item)).toList();
      } else {
        throw ApiException('Помилка сервера: ${response.statusCode}');
      }
    });
  }

  /// POST /posts: створює нову заявку (сервер відповідає кодом 201).
  Future<Post> createPost(String title, String body) {
    return _guard(() async {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/posts'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'title': title, 'body': body, 'userId': 1}),
          )
          .timeout(_timeout);

      if (response.statusCode == 201) {
        return Post.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException('Не вдалося створити запис: ${response.statusCode}');
      }
    });
  }

  /// Єдине місце, де винятки мережі перетворюються на зрозумілі повідомлення.
  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on SocketException {
      throw ApiException('Немає з’єднання з інтернетом');
    } on TimeoutException {
      throw ApiException('Сервер не відповів вчасно (тайм-аут)');
    } on http.ClientException {
      throw ApiException('Помилка мережі. Перевірте підключення');
    } on FormatException {
      throw ApiException('Сервер повернув некоректні дані');
    }
  }
}