import 'dart:io';
import 'package:custom_cam_picker/PhotoSelectScreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  File? _image;
  final picker = ImagePicker();

  // 비동기 처리를 통해 카메라와 갤러리에서 이미지를 가져온다.
  Future getImage(ImageSource imageSource) async {
    final image = await picker.pickImage(source: imageSource);
    print("imageSource: "+imageSource!.toString());
    // setState(() {
    //   _image = File(image!.path); // 가져온 이미지를 _image에 저장
    // });
  }


  Future<Widget> photoScreen() async {
    // 앨범 목록
    List<AssetPathEntity> album = await PhotoManager.getAssetPathList();

// 앨범 이미지 목록
    List<AssetEntity> images = await album[0].getAssetListPaged(page: 0, size: 80);

    return GridView(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      children: images.map((AssetEntity e) =>
      // AssetEntityImage
      AssetEntityImage(e, isOriginal: false)
      ).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 갤러리에서 이미지를 가져오는 버튼
            FloatingActionButton(
              child: Icon(Icons.wallpaper),
              tooltip: 'image_picker',
              onPressed: () {
                // getImage(ImageSource.gallery);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PhotoSelectScreen()));
              },
            ),
          ],
        ),
      ),

    );
  }
}
