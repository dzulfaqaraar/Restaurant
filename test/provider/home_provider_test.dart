import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:restaurant/common/request_state.dart';
import 'package:restaurant/data/model/restaurant.dart';
import 'package:restaurant/provider/home_provider.dart';

import '../utils/test_helper.dart';
import '../utils/test_helper.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late MockConnectivity mockConnectivity;
  late HomeProvider provider;

  setUp(() {
    mockApiService = MockApiService();
    mockConnectivity = MockConnectivity();
    provider = HomeProvider(
      apiService: mockApiService,
      connectivity: mockConnectivity,
    );
  });

  test('should return the data when calling fetchListRestaurant is success', () async {
    // arrange
    dynamic data = readJson('responses/list_response.json');
    List<Restaurant> restaurantList = (json.decode(data)['restaurants'] as List<dynamic>)
        .map((e) => Restaurant.fromJson(e))
        .toList();

    when(mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => ConnectivityResult.mobile);
    when(mockApiService.listRestaurant())
        .thenAnswer((_) async => restaurantList);

    // act
    await provider.fetchListRestaurant();

    // assert
    expect(provider.state, RequestState.data);
    expect(provider.restaurantResult, restaurantList);
  });
}
