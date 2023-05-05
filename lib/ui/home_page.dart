import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../common/common.dart';
import '../common/navigation.dart';
import '../common/request_state.dart';
import '../common/string_ext.dart';
import '../common/styles.dart';
import '../data/model/restaurant.dart';
import '../provider/favorite_provider.dart';
import '../provider/home_provider.dart';
import '../widgets/empty_data_view.dart';
import '../widgets/failed_data_view.dart';
import '../widgets/no_connection_view.dart';
import '../widgets/rating_view.dart';
import 'restaurant_page.dart';
import 'setting_page.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  final String? restaurantId;

  const HomePage({
    Key? key,
    this.restaurantId,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  Icon customIcon = const Icon(Icons.search);
  Widget? customSearchBar;
  final _searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final RefreshController _refreshControllerHome =
      RefreshController(initialRefresh: false);
  final RefreshController _refreshControllerFavorite =
      RefreshController(initialRefresh: false);

  late TabController _tabController;
  int _tabIndex = 0;
  List<Tab> _tabs = [
    const Tab(icon: Icon(Icons.home), text: ''),
    const Tab(icon: Icon(Icons.star), text: ''),
  ];
  void _onTabTapped(int index) {
    setState(() {
      _tabIndex = index;
      _searchReset();
    });
  }

  void _initTabBarItem() {
    setState(() {
      _tabs = [
        Tab(
          icon: const Icon(Icons.home),
          text: AppLocalizations.of(context)?.home,
        ),
        Tab(
          icon: const Icon(Icons.star),
          text: AppLocalizations.of(context)?.favorite,
        ),
      ];
    });
  }

  void _onRefresh() async {
    if (_tabIndex == 0) {
      _refreshControllerHome.refreshCompleted();

      final homeProvider = Provider.of<HomeProvider>(context, listen: false);

      if (customIcon.icon == Icons.cancel) {
        homeProvider.keywordSearch = null;
        homeProvider.searchRestaurant(keywordSearch: _searchController.text);
      } else {
        homeProvider.fetchListRestaurant();
      }
    } else {
      _refreshControllerFavorite.refreshCompleted();

      final favoriteProvider = Provider.of<FavoriteProvider>(
        context,
        listen: false,
      );

      if (customIcon.icon == Icons.cancel) {
        favoriteProvider.getAllRestaurantsByName(_searchController.text);
      } else {
        favoriteProvider.getAllRestaurants();
      }
    }
  }

  void _onSearch(String text) {
    if (_tabIndex == 0) {
      Provider.of<HomeProvider>(context, listen: false)
          .searchRestaurant(keywordSearch: text);
    } else {
      Provider.of<FavoriteProvider>(context, listen: false)
          .getAllRestaurantsByName(text);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    Future.delayed(Duration.zero, () {
      if (widget.restaurantId != null) {
        Navigation.intentWithData(
          RestaurantPage.routeName,
          arguments: widget.restaurantId,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initTabBarItem();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    customSearchBar ??= Localizations.override(
      context: context,
      locale: const Locale('id'),
      child: Builder(
        builder: (BuildContext context) {
          return Text(AppLocalizations.of(context)?.titleApp ?? '');
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: customSearchBar,
        actions: [
          _searchIcon(),
          if (customIcon.icon == Icons.search)
            IconButton(
              onPressed: () {
                Navigation.intentWithData(SettingPage.routeName);
              },
              icon: const Icon(Icons.settings),
            )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          onTap: _onTabTapped,
        ),
      ),
      body: _tabIndex == 0 ? _homeContent() : _favoriteContent(),
    );
  }

  Widget _searchIcon() {
    return IconButton(
      onPressed: () {
        setState(() {
          if (customIcon.icon == Icons.search) {
            customIcon = const Icon(Icons.cancel);
            customSearchBar = ListTile(
              leading: const Icon(
                Icons.search,
                color: Colors.white,
                size: 28,
              ),
              title: TextField(
                controller: _searchController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)?.search,
                  hintStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontStyle: FontStyle.normal,
                  ),
                  border: InputBorder.none,
                ),
                style: myTextTheme.bodyMedium,
                onChanged: (text) {
                  _onSearch(text);
                },
              ),
            );

            focusNode.requestFocus();
          } else {
            _searchReset();

            if (_tabIndex == 0) {
              Provider.of<HomeProvider>(context, listen: false)
                  .fetchListRestaurant();
            } else {
              Provider.of<FavoriteProvider>(context, listen: false)
                  .getAllRestaurants();
            }
          }
        });
      },
      icon: customIcon,
    );
  }

  void _searchReset() {
    customIcon = const Icon(Icons.search);
    customSearchBar = null;
    focusNode.unfocus();
    _searchController.text = '';
  }

  Widget _homeContent() {
    return Consumer<HomeProvider>(
      builder: (context, data, child) {
        if (data.state == RequestState.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return SmartRefresher(
            enablePullDown: true,
            controller: _refreshControllerHome,
            onRefresh: _onRefresh,
            child: data.state == RequestState.data
                ? _listRestaurant(data.restaurantResult)
                : data.state == RequestState.connection
                    ? const NoConnectionView()
                    : data.state == RequestState.error
                        ? const FailedDataView()
                        : const EmptyDataView(),
          );
        }
      },
    );
  }

  Widget _favoriteContent() {
    return Consumer<FavoriteProvider>(
      builder: (context, data, child) {
        if (data.state == RequestState.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return SmartRefresher(
            enablePullDown: true,
            controller: _refreshControllerFavorite,
            onRefresh: _onRefresh,
            child: data.favoriteResult.isNotEmpty
                ? _listRestaurant(data.favoriteResult)
                : const EmptyDataView(),
          );
        }
      },
    );
  }

  Widget _listRestaurant(List<Restaurant> restaurants) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigation.intentWithData(
                RestaurantPage.routeName,
                arguments: restaurant.id,
              );
            },
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: restaurant.id ?? '',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      restaurant.pictureId?.smallImage() ?? '',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, obj, e) {
                        return Image.asset(
                          'assets/images/no-image.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        restaurant.name ?? '',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        restaurant.city ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      RatingView(rating: restaurant.rating),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      itemCount: restaurants.length,
    );
  }
}
