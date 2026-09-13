import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/models/sdlc_models.dart';

void main() async {
  final loginRes = await http.post(
    Uri.parse('http://localhost:4000/api/v1/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': 'admin@chronos.local', 'password': 'password123'})
  );
  final token = jsonDecode(loginRes.body)['token'];
  print('Token: \$token');

  final projRes = await http.get(
    Uri.parse('http://localhost:4000/api/v1/projects'),
    headers: {'Authorization': 'Bearer \$token'}
  );
  
  final List data = jsonDecode(projRes.body);
  final projects = data.map((json) => Project.fromJson(json)).toList();
  
  for (var p in projects) {
    print('Project \${p.id}: \${p.name}, userRole = \${p.userRole}');
  }
}
