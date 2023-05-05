const _imageSmallUrl = 'https://restaurant-api.dicoding.dev/images/small';
const _imageMediumUrl = 'https://restaurant-api.dicoding.dev/images/medium';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String smallImage() {
    return '$_imageSmallUrl/$this';
  }

  String mediumImage() {
    return '$_imageMediumUrl/$this';
  }
}
