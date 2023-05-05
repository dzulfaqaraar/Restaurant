import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../common/common.dart';
import '../common/navigation.dart';
import '../common/request_state.dart';
import '../common/string_ext.dart';
import '../common/styles.dart';
import '../data/model/restaurant.dart';
import '../data/model/review.dart';
import '../provider/favorite_provider.dart';
import '../provider/restaurant_provider.dart';
import '../widgets/empty_data_view.dart';
import '../widgets/failed_data_view.dart';
import '../widgets/no_connection_view.dart';
import '../widgets/rating_view.dart';

class RestaurantPage extends StatefulWidget {
  static const routeName = '/restaurant';
  final String restaurantId;

  const RestaurantPage({
    Key? key,
    required this.restaurantId,
  }) : super(key: key);

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  int _bottomNavIndex = 0;
  int _reviewStep = 1;
  bool isFavorited = false;

  final _reviewNameController = TextEditingController();
  final _reviewMessageController = TextEditingController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<BottomNavigationBarItem> _bottomNavBarItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.info_outline_rounded),
      label: '',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.food_bank_rounded),
      label: '',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.local_drink_rounded),
      label: '',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.reviews_rounded),
      label: '',
    ),
  ];

  void _onBottomNavTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
    });
  }

  void _initBottomNavigationBarItem() {
    setState(() {
      _bottomNavBarItems = [
        BottomNavigationBarItem(
          icon: const Icon(Icons.info_outline_rounded),
          label: AppLocalizations.of(context)?.about,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.food_bank_rounded),
          label: AppLocalizations.of(context)?.food,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.local_drink_rounded),
          label: AppLocalizations.of(context)?.drink,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.reviews_rounded),
          label: AppLocalizations.of(context)?.review,
        ),
      ];
    });
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      _initBottomNavigationBarItem();
      _onRefresh();
    });
  }

  void _onRefresh() async {
    _refreshController.refreshCompleted();

    Provider.of<RestaurantProvider>(context, listen: false)
        .loadDetailRestaurant(widget.restaurantId);

    final favorited = await Provider.of<FavoriteProvider>(
      context,
      listen: false,
    ).getRestaurantById(widget.restaurantId);

    setState(() {
      isFavorited = favorited;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _reviewNameController.dispose();
    _reviewMessageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantProvider>(
      builder: (context, data, child) {
        if (data.stateSubmit == RequestState.connection) {
          Provider.of<RestaurantProvider>(context, listen: false)
              .showNoConnection(context);
        }

        if (data.stateData == RequestState.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (data.stateData == RequestState.data) {
          return Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _bottomNavIndex,
              items: _bottomNavBarItems,
              onTap: _onBottomNavTapped,
            ),
            body: _detailRestaurant(data.restaurantResult),
            floatingActionButton: _bottomNavIndex == 3
                ? FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _reviewStep = 1;
                        _reviewNameController.text = '';
                        _reviewMessageController.text = '';
                      });
                      _showDialogReview();
                    },
                    backgroundColor: Colors.white,
                    foregroundColor: primaryColor,
                    child: const Icon(Icons.add),
                  )
                : null,
          );
        } else {
          return Scaffold(
            body: SmartRefresher(
              enablePullDown: true,
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: data.stateData == RequestState.connection
                  ? const NoConnectionView()
                  : data.stateData == RequestState.error
                      ? const FailedDataView()
                      : const EmptyDataView(),
            ),
          );
        }
      },
    );
  }

  Widget _detailRestaurant(Restaurant restaurant) {
    return CustomScrollView(
      slivers: [
        _restaurantHeader(restaurant),
        _restaurantContent(restaurant),
      ],
    );
  }

  Widget _restaurantHeader(Restaurant restaurant) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 200,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          restaurant.name ?? '',
          style: myTextTheme.headline6,
        ),
        expandedTitleScale: 1,
        centerTitle: true,
        titlePadding: const EdgeInsets.symmetric(vertical: 10),
        background: Stack(
          children: [
            Center(
              child: restaurant.pictureId != null
                  ? Hero(
                      tag: restaurant.id ?? '',
                      child: Image.network(
                        restaurant.pictureId?.mediumImage() ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (ctx, obj, e) {
                          return Image.asset(
                            'assets/images/no-image.png',
                            fit: BoxFit.cover,
                            height: double.infinity,
                          );
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  height: kToolbarHeight,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: secondaryColor.withOpacity(0.9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () async {
            final status = await Provider.of<FavoriteProvider>(
              context,
              listen: false,
            ).changeFavorite(
              !isFavorited,
              restaurant,
            );
            if (status) {
              setState(() {
                isFavorited = !isFavorited;
              });
            }
          },
          icon: Icon(isFavorited ? Icons.star : Icons.star_border),
        ),
      ],
    );
  }

  Widget _restaurantContent(Restaurant restaurant) {
    switch (_bottomNavIndex) {
      case 0:
        return _restaurantAbout(restaurant);
      case 1:
        final foods =
            restaurant.menus?.foods?.map((e) => e.name ?? '').toList();
        foods?.sort(
          (a, b) => (a).compareTo(b),
        );
        return _restaurantMenu(menuItems: foods);
      case 2:
        final drinks =
            restaurant.menus?.drinks?.map((e) => e.name ?? '').toList();
        drinks?.sort(
          (a, b) => (a).compareTo(b),
        );
        return _restaurantMenu(menuItems: drinks);
      case 3:
        final reviews = restaurant.customerReviews ?? [];
        return _restaurantReviews(reviews);
      default:
        return const SliverToBoxAdapter(
          child: SizedBox.shrink(),
        );
    }
  }

  Widget _restaurantAbout(Restaurant restaurant) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)?.location ?? '',
              style: myTextTheme.titleLarge,
            ),
            Text(
              restaurant.city ?? '',
              style: myTextTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.address ?? '',
              style: myTextTheme.titleLarge,
            ),
            Text(
              restaurant.address ?? '',
              style: myTextTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.rating ?? '',
              style: myTextTheme.titleLarge,
            ),
            RatingView(rating: restaurant.rating),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.description ?? '',
              style: myTextTheme.titleLarge,
            ),
            Text(
              restaurant.description ?? '',
              style: myTextTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _restaurantMenu({List<String>? menuItems}) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = menuItems![index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              item.capitalize(),
              style: myTextTheme.bodyMedium,
            ),
          );
        },
        childCount: menuItems?.length,
      ),
    );
  }

  Widget _restaurantReviews(List<Review> reviews) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = reviews[index];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  item.name ?? '',
                  style: myTextTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  item.date ?? '',
                  style: myTextTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  item.review ?? '',
                  style: myTextTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
        childCount: reviews.length,
      ),
    );
  }

  Future<dynamic> _showDialogReview() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)?.reviewTitle ?? '',
            style: myTextTheme.apply(bodyColor: primaryColor).headline6,
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                if (_reviewStep == 1)
                  TextField(
                    autofocus: true,
                    controller: _reviewNameController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)?.reviewName,
                    ),
                    style: myTextTheme.apply(bodyColor: primaryColor).bodyText1,
                    onSubmitted: (text) {},
                  ),
                if (_reviewStep == 2)
                  TextField(
                    autofocus: true,
                    controller: _reviewMessageController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)?.reviewMessage,
                    ),
                    style: myTextTheme.apply(bodyColor: primaryColor).bodyText1,
                    onSubmitted: (text) {},
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                _reviewStep == 1
                    ? AppLocalizations.of(context)?.reviewNext ?? ''
                    : AppLocalizations.of(context)?.reviewButton ?? '',
              ),
              onPressed: () {
                if (_reviewStep == 1) {
                  if (_reviewNameController.text.isEmpty) return;
                  setState(() {
                    _reviewStep = 2;
                  });

                  Navigation.back();
                  _showDialogReview();
                } else {
                  if (_reviewMessageController.text.isEmpty) return;

                  Provider.of<RestaurantProvider>(
                    context,
                    listen: false,
                  ).submitReviewRestaurant(
                    _reviewNameController.text,
                    _reviewMessageController.text,
                  );
                  Navigation.back();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
