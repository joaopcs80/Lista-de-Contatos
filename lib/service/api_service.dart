import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://parseapi.back4app.com/classes/ListadeContatos',
    headers: {
      'X-Parse-Application-Id': 'EEc5M90U1c1ll4j4ghCvczxdkMeu8GTSeb4wJulf',
      'X-Parse-REST-API-Key': 'H4fVRNm250sKQOUD4479fpJKkI7RzWR1XZkzvFDr',
      'Content-Type': 'application/json',
    },
  ));

  Future<void> createPerson(String name, String phone, String email, String profilePicPath) async {
    try {
      final response = await _dio.post(
        'Person',
        data: {
          'name': name,
          'phone': phone,
          'email': email,
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

  Future<void> updatePerson(String objectId, String name, String phone, String email, String profilePicPath) async {
    try {
      final response = await _dio.put(
        'Person/$objectId',
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'profilePicPath': profilePicPath,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update person: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to update person: $e');
    }
  }

  Future<void> deletePerson(String objectId) async {
    try {
      final response = await _dio.delete('Person/$objectId');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete person: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Failed to delete person: $e');
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