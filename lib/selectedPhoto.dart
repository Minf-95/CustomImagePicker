import 'package:image_cropper/image_cropper.dart';
import 'package:photo_manager/photo_manager.dart';

class SelectedPhoto {
  //선택 된 이미지가 무엇인지 저장
  AssetEntity images;
  //선택되었는지 안되었는지
  bool selected;
  //미리보기 리스트에서의 이미지 인덱스 (= 갤러리 리스트에서의 카운트 번호)
  int count;
  //갤러리 리스트에서의 이미지 인덱스
  int imageIndex;
  //크롭된거면 true, 아니면 false
  bool cropStatus;
  //크롭 된 이미지 경로를 저장해주는 변수
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