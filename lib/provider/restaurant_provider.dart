import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../common/common.dart';
import '../l10n/app_localizations.dart';
import '../common/request_state.dart';
import '../data/api/api_service.dart';
import '../data/model/add_review.dart';
import '../data/model/restaurant.dart';

class RestaurantProvider extends ChangeNotifier {
  final ApiService apiService;
  final Connectivity connectivity;

  RestaurantProvider({
    required this.apiService,
    required this.connectivity,
  });

  RequestState _stateData = RequestState.empty;
  RequestState get stateData => _stateData;

  RequestState _stateSubmit = RequestState.empty;
  RequestState get stateSubmit => _stateSubmit;

  Restaurant _restaurantResult = const Restaurant();
  Restaurant get restaurantResult => _restaurantResult;

  Future loadDetailRestaurant(String id) async {
    _stateData = RequestState.loading;
    notifyListeners();

    try {
      final connectionStatus = await connectivity.checkConnectivity();
      if (!(connectionStatus.contains(ConnectivityResult.wifi) ||
          connectionStatus.contains(ConnectivityResult.mobile))) {
        _stateData = RequestState.connection;
        notifyListeners();
        return;
      }

      final result = await apiService.detailRestaurant(id);

      if (result == null) {
        _stateData = RequestState.empty;
        notifyListeners();
      } else {
        _restaurantResult = result;

        _stateData = RequestState.data;
        notifyListeners();
      }
    } catch (e) {
      _stateData = RequestState.error;
      notifyListeners();
    }
  }

  Future submitReviewRestaurant(String name, String message) async {
    _stateSubmit = RequestState.loading;
    notifyListeners();

    try {
      final connectionStatus = await connectivity.checkConnectivity();
      if (!(connectionStatus.contains(ConnectivityResult.wifi) ||
          connectionStatus.contains(ConnectivityResult.mobile))) {
        _stateSubmit = RequestState.connection;
        notifyListeners();
        return;
      }

      final request = AddReview(
        id: restaurantResult.id,
        name: name,
        review: message,
      );
      final result = await apiService.reviewRestaurant(request);

      _restaurantResult.customerReviews?.addAll(result);

      _stateSubmit = RequestState.data;
      notifyListeners();
    } catch (e) {
      _stateSubmit = RequestState.error;
      notifyListeners();
    }
  }

  void showNoConnection(BuildContext context) {
    Fluttertoast.showToast(
      msg: AppLocalizations.of(context)?.noConnection ?? '',
    );

    _stateSubmit = RequestState.empty;
    notifyListeners();
  }
}
