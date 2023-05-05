import 'package:flutter/material.dart';

import '../common/request_state.dart';
import '../data/local/database_helper.dart';
import '../data/model/restaurant.dart';

class FavoriteProvider extends ChangeNotifier {
  late DatabaseHelper _dbHelper;

  FavoriteProvider() {
    _dbHelper = DatabaseHelper();
    getAllRestaurants();
  }

  RequestState _state = RequestState.empty;
  RequestState get state => _state;

  List<Restaurant> _favoriteResult = [];
  List<Restaurant> get favoriteResult => _favoriteResult;

  void getAllRestaurants() async {
    _state = RequestState.loading;
    notifyListeners();

    _favoriteResult = await _dbHelper.getRestaurants();

    _state = RequestState.data;
    notifyListeners();
  }

  Future<bool> getRestaurantById(String id) async {
    final restaurant = await _dbHelper.getRestaurantById(id);
    return restaurant != null;
  }

  Future<bool> changeFavorite(bool isAdding, Restaurant restaurant) async {
    if (isAdding) {
      await _dbHelper.insertRestaurant(restaurant);
    } else {
      await _dbHelper.deleteRestaurant(restaurant.id ?? '');
    }

    _favoriteResult = await _dbHelper.getRestaurants();
    notifyListeners();

    return true;
  }

  void getAllRestaurantsByName(String name) async {
    _favoriteResult = await _dbHelper.getRestaurantByName(name);

    _state = RequestState.data;
    notifyListeners();
  }
}
