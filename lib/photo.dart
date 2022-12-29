import 'package:photo_manager/photo_manager.dart';

class Photo {
  //이미지 소스
  AssetEntity images;
  //선택된 건지 아닌지 확인해주는 bool
  bool selected;
  //index넘버
  int count;
  //선택 된 넘버 (프로필 미리보기 리스트)
  int selectedCount;

  Photo({
    required this.images,
    required this.selected,
    required this.count,
    required this.selectedCount,
  });
}