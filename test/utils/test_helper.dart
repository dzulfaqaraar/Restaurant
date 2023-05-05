import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mockito/annotations.dart';
import 'package:restaurant/data/api/api_service.dart';
import 'package:http/http.dart' as http;

@GenerateMocks([
  ApiService,
  Connectivity,
], customMocks: [
  MockSpec<http.Client>(as: #MockHttpClient)
])
void main() {}

String readJson(String name) {
  var dir = Directory.current.path;
  if (dir.endsWith('/test')) {
    dir = dir.replaceAll('/test', '');
  }
  return File('$dir/test/$name').readAsStringSync();
}
