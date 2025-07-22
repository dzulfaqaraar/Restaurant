import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:restaurant/data/api/api_service.dart';
import 'package:restaurant/data/model/restaurant.dart';
import 'package:http/http.dart' as http;

import '../utils/test_helper.dart';
import '../utils/test_helper.mocks.dart';

void main() {
  late MockHttpClient mockHttpClient;
  late ApiService service;

  setUp(() {
    mockHttpClient = MockHttpClient();
    service = ApiService(client: mockHttpClient);
  });

  test('should return the list of restaurants when the response is success',
      () async {
    // arrange
    String data = readJson('responses/list_response.json');
    List<Restaurant> restaurantList =
        (json.decode(data)['restaurants'] as List<dynamic>)
            .map((e) => Restaurant.fromJson(e))
            .toList();

    when(mockHttpClient.get(Uri.parse(ApiService.list)))
        .thenAnswer((_) async => http.Response(data, 200));

    // act
    final result = await service.listRestaurant();

    // assert
    expect(result, restaurantList);
  });

  test('should return empty list when the response has error flag true',
      () async {
    // arrange
    String data = '{"error": true, "message": "Error occurred", "restaurants": []}';

    when(mockHttpClient.get(Uri.parse(ApiService.list)))
        .thenAnswer((_) async => http.Response(data, 200));

    // act
    final result = await service.listRestaurant();

    // assert
    expect(result, []);
  });

  test('should throw exception when the response code is not 200', () async {
    // arrange
    when(mockHttpClient.get(Uri.parse(ApiService.list)))
        .thenAnswer((_) async => http.Response('Error', 404));

    // act & assert
    expect(() => service.listRestaurant(), throwsException);
  });

  test('should search restaurants when keywordSearch is provided', () async {
    // arrange
    String data = readJson('responses/list_response.json');
    String keyword = 'Melting';
    
    when(mockHttpClient.get(Uri.parse('${ApiService.search}?q=$keyword')))
        .thenAnswer((_) async => http.Response(data, 200));

    // act
    final result = await service.listRestaurant(keywordSearch: keyword);

    // assert
    expect(result, isA<List<Restaurant>>());
    verify(mockHttpClient.get(Uri.parse('${ApiService.search}?q=$keyword')));
  });
}
