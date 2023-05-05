import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../common/request_state.dart';
import '../data/api/api_service.dart';
import '../data/model/restaurant.dart';

class HomeProvider extends ChangeNotifier {
  final ApiService apiService;
  final Connectivity connectivity;

  HomeProvider({
    required this.apiService,
    required this.connectivity,
  }) {
    fetchListRestaurant();
  }

  RequestState _state = RequestState.empty;
  RequestState get state => _state;

  List<Restaurant> _restaurantResult = [];
  List<Restaurant> get restaurantResult => _restaurantResult;

  Timer? _debounce;
  String? keywordSearch;

  Future searchRestaurant({String? keywordSearch}) async {
    if (this.keywordSearch == keywordSearch) return;

    this.keywordSearch = keywordSearch;
    if (keywordSearch?.isNotEmpty ?? false) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();

      _debounce = Timer(const Duration(milliseconds: 1000), () {
        fetchListRestaurant(keywordSearch: keywordSearch);
      });
    }
  }

  Future fetchListRestaurant({String? keywordSearch}) async {
    _state = RequestState.loading;
    notifyListeners();

    try {
      final connectionStatus = await connectivity.checkConnectivity();
      if (!(connectionStatus == ConnectivityResult.wifi ||
          connectionStatus == ConnectivityResult.mobile)) {
        _state = RequestState.connection;
        notifyListeners();
        return;
      }

      final result =
          await apiService.listRestaurant(keywordSearch: keywordSearch);
      this.keywordSearch = null;

      if (result.isEmpty) {
        _state = RequestState.empty;
        notifyListeners();
      } else {
        _restaurantResult = result;

        _state = RequestState.data;
        notifyListeners();
      }
    } catch (e) {
      _state = RequestState.error;
      notifyListeners();
    }
  }
}
