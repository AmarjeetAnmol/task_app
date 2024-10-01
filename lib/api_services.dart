// lib/api_services.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_app/test_model.dart';



class ApiServices {
  final String _apiKey = '46281067-87cc3692cf4ffbc9f75310fba'; // Your Pixabay API key
  final String _baseUrl = 'https://pixabay.com/api/';

  Future<TestModel?> fetchImages({int page = 1, String query = 'yellow+flowers'}) async {
    final url = '$_baseUrl?key=$_apiKey&q=$query&image_type=photo&pretty=true&page=$page&per_page=20';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return TestModel.fromJson(responseData);
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}