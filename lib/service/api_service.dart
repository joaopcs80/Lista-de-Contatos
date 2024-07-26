import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://parseapi.back4app.com/classes/',
    headers: {
      'X-Parse-Application-Id': 'YOUR_APPLICATION_ID',
      'X-Parse-Client-Key': 'YOUR_CLIENT_KEY',
      'Content-Type': 'application/json',
    },
  ));

  Future<void> createPerson(String name, String profilePicPath) async {
    try {
      final response = await _dio.post(
        'Person',
        data: {
          'name': name,
          'profilePicPath': profilePicPath,
        },
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to create person: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to create person: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchPeople() async {
    try {
      final response = await _dio.get('Person');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['results']);
      } else {
        throw Exception('Failed to fetch people: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to fetch people: $e');
    }
  }
}