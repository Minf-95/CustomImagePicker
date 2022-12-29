import 'package:custom_cam_picker/photo.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GridPhoto extends StatefulWidget {
  List<AssetEntity> images;

  GridPhoto({
    required this.images,
    Key? key,
  }) : super(key: key);

  @override
  State<GridPhoto> createState() => _GridPhotoState();
}

class _GridPhotoState extends State<GridPhoto> {
  List<Photo> _photo =[];
  int count = 0;


  @override
  Widget build(BuildContext context) {
    return GridView(
      physics: const BouncingScrollPhysics(),
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      children: widget.images.map((AssetEntity e) {
        var currentCount = count;
        _photo.add(Photo(images: e, selected: false,count: count,selectedCount: 100));
        count++;

        return InkWell(
          onTap: (){
            showToast(_photo[currentCount].count);
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 1,color: Colors.red)
            ),
            child: AssetEntityImage(
              e,
              isOriginal: false,
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
    );
  }

  void showToast(text){
    Fluttertoast.showToast(msg: text.toString(),gravity: ToastGravity.BOTTOM);
  }
}