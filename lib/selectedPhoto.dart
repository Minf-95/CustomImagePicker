import 'package:image_cropper/image_cropper.dart';
import 'package:photo_manager/photo_manager.dart';

class SelectedPhoto {
  AssetEntity images;
  bool selected;
  int count;
  int imageIndex;
  //크롭된거면 true, 아니면 false
  bool cropStatus;
  String? cropImagePath;


  SelectedPhoto({
    required this.images,
    required this.selected,
    required this.count,
    required this.imageIndex,
    required this.cropStatus,
    this.cropImagePath,
  });
}