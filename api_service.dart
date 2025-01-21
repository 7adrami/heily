// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student.dart';
import '../models/absence.dart';

class ApiService {
  // Make sure this IP address matches your computer's IP address on the network
  // Don't use localhost or 127.0.0.1
  static const String baseUrl = 'http://192.168.1.89:5000'; // Replace X with your IP's last number

  Future<Student> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/student/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Student.fromJson(data['student']);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to login');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getStudentAbsences(int matricule) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/student/$matricule/absences'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final student = Student.fromJson(data['student']);
        final absences = (data['absences'] as List)
            .map((absence) => Absence.fromJson(absence))
            .toList();

        return {
          'student': student,
          'absences': absences,
        };
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to load absences');
      }
    } catch (e) {
      print('Get absences error: $e');
      throw Exception('Network error: $e');
    }
  }
}