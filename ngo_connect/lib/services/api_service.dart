import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // ── AUTH ──────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password, 'role': role}),
    );
    return jsonDecode(response.body);
  }

  // ── NEEDS ─────────────────────────────────────────
  static Future<List<dynamic>> getNeeds() async {
    final response = await http.get(Uri.parse('$baseUrl/needs/'));
    final data = jsonDecode(response.body);
    return data['needs'];
  }

  static Future<Map<String, dynamic>> createNeed(Map<String, dynamic> need) async {
    final response = await http.post(
      Uri.parse('$baseUrl/needs/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(need),
    );
    return jsonDecode(response.body);
  }

  // ── AI MATCHING ───────────────────────────────────
  static Future<Map<String, dynamic>> getMatches(String volunteerId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/match/volunteer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'volunteer_id': volunteerId}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> prioritizeNeeds() async {
    final response = await http.get(Uri.parse('$baseUrl/match/prioritize-needs'));
    return jsonDecode(response.body);
  }

  // ── ANALYTICS ─────────────────────────────────────
  static Future<Map<String, dynamic>> getAnalytics() async {
    final response = await http.get(Uri.parse('$baseUrl/analytics/'));
    return jsonDecode(response.body);
  }
}