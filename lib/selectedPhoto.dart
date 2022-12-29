import 'package:photo_manager/photo_manager.dart';

class SelectedPhoto {
  AssetEntity images;
  bool selected;
  int count;
  int imageIndex;

  SelectedPhoto({
    required this.images,
    required this.selected,
    required this.count,
    required this.imageIndex,

  });
}