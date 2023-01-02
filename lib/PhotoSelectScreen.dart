import 'dart:io';

import 'package:custom_cam_picker/photo.dart';
import 'package:custom_cam_picker/selectedPhoto.dart';
import 'package:flutter/foundation.dart';
// import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image_cropper/image_cropper.dart';

import 'GridPhoto.dart';
import 'album.dart';

class PhotoSelectScreen extends StatefulWidget {
  const PhotoSelectScreen({Key? key}) : super(key: key);

  @override
  State<PhotoSelectScreen> createState() => _PhotoSelectScreenState();
}

class _PhotoSelectScreenState extends State<PhotoSelectScreen> {
  List<AssetPathEntity>? _paths;
  List<Album> _albums = [];
  late List<AssetEntity> _images;
  int _currentPage = 0;
  late Album _currentAlbum;
  List<Photo> _photo = [];
  late List<SelectedPhoto> selectedPhoto = [];
  int count = 0;
  int selectedCount = -1;
  int listCount = 0;

  CroppedFile? _croppedFile;

  Future<void> _cropImage(int index) async {
    AssetEntity entity = selectedPhoto[index].images;
    File? file = await entity.file;
    var path = file!.path;
    print("_images[1].relativePath.toString() : " + path);
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      aspectRatio: CropAspectRatio(ratioX: 3.0, ratioY: 4.0),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "자르기 및 회전",
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          hideBottomControls: true,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: "자르기 및 회전",
          cancelButtonTitle: "취소",
          doneButtonTitle: "완료",
          hidesNavigationBar: true,
        ),
        WebUiSettings(
          context: context,
          presentStyle: CropperPresentStyle.dialog,
          boundary: const CroppieBoundary(
            width: 520,
            height: 520,
          ),
          viewPort:
              const CroppieViewPort(width: 480, height: 480, type: 'circle'),
          enableExif: true,
          enableZoom: true,
          showZoomer: true,
        ),
      ],
    );
    if (croppedFile != null) {
      bool checkCropStatus = true;
      int nonCropIndex = 0;

      setState(() {
        _croppedFile = croppedFile;
        selectedPhoto[index].cropStatus = true;
        selectedPhoto[index].cropImagePath = _croppedFile!.path.toString();
      });
      for (var i = 0; i <= 1; i++) {
        if (selectedPhoto[i].cropStatus == false) {
          checkCropStatus = false;
          nonCropIndex = i;
          break;
        }
      }
      if (checkCropStatus == false) {
        showToast("크롭해주세요" + nonCropIndex.toString());
        _cropImage(nonCropIndex);
      }else{
        showToast("끝" + nonCropIndex.toString());

      }

    }
    // }
  }

  Future<void> checkPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    print("ps.isAuth: " + ps.isAuth.toString());
    if (ps.isAuth) {
      await getAlbum();
    } else {
      await PhotoManager.openSetting();
    }
  }

  Future<void> getAlbum() async {
    _paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
    );
    print("_paths_paths: " + _paths.toString());

    _albums = _paths!.map((e) {
      return Album(
        id: e.id,
        name: e.isAll ? '모든 사진' : e.name,
      );
    }).toList();

    await getPhotos(_albums[0], albumChange: true);
  }

  Future<void> getPhotos(
    Album album, {
    bool albumChange = false,
  }) async {
    _currentAlbum = album;
    albumChange ? _currentPage = 0 : _currentPage++;

    final loadImages = await _paths!
        .singleWhere((element) => element.id == album.id)
        .getAssetListPaged(
          page: _currentPage,
          size: 20,
        );
    setState(() {
      if (albumChange) {
        _images = loadImages;
      } else {
        _images.addAll(loadImages);
      }
      // setState(() {
      //   for (var i = 0; i <= 5; i++) {
      //     selectedPhoto.add(SelectedPhoto(
      //         images: _images[i], selected: false, count: 0, imageIndex: 0));
      //   }
      // }
      // );
    });
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, size: 30, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: PreferredSize(
            child: Container(
              color: Colors.grey,
              height: 0.5,
            ),
            preferredSize: const Size.fromHeight((0.5)),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            "프로필 사진 관리",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                bool checkCropStatus = true;
                int nonCropIndex = 0;
                for (var i = 0; i <= 1; i++) {
                  if (selectedPhoto[i].cropStatus == false) {
                    checkCropStatus = false;
                    nonCropIndex = i;
                    break;
                  }
                }
                if (checkCropStatus == false) {
                  showToast("크롭해주세요" + nonCropIndex.toString());
                  _cropImage(nonCropIndex);
                }

                for (var i = 0; i < selectedPhoto.length; i++) {
                  print("------- selectedPhoto Index:  " + i.toString() + " -------");
                  print("selectedPhoto[i]imageIndex : " + selectedPhoto[i].imageIndex.toString());
                  print("selectedPhoto[i]count : " + selectedPhoto[i].count.toString());
                  print("selectedPhoto[i]selected : " + selectedPhoto[i].selected.toString());
                  print("selectedPhoto[i]cropStatus : " + selectedPhoto[i].cropStatus.toString());
                  print("-----------------------");
                }

                for(var i=0 ; i< _photo.length;i++){
                  if(_photo[i].selected){
                    print("------- _photo Index:  " + i.toString() + " -------");
                    print("_photo[i]count : " + _photo[i].count.toString());
                    print("_photo[i]selectedCount : " + _photo[i].selectedCount.toString());
                    print("-----------------------");
                  }
                }
              },
              child: Text(
                "완료",
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                  splashFactory: NoSplash.splashFactory),
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //프로필 미리보기 영역 시작 ------
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(
                                margin: EdgeInsets.fromLTRB(0, 5, 5, 5),
                                height: MediaQuery.of(context).size.width,
                                child: selectedPhoto.length > 0
                                    ? selectedBoxContainer(0)
                                    : emptyImageBox()),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                                margin: EdgeInsets.fromLTRB(0, 5, 5, 5),
                                height: MediaQuery.of(context).size.width,
                                child: selectedPhoto.length > 1
                                    ? selectedBoxContainer(1)
                                    : emptyImageBox()),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                                margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                height: MediaQuery.of(context).size.width,
                                child: selectedPhoto.length > 2
                                    ? selectedBoxContainer(2)
                                    : emptyImageBox()),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      flex: 1,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 5, 5),
                                height: MediaQuery.of(context).size.width,
                                child: selectedPhoto.length > 3
                                    ? selectedBoxContainer(3)
                                    : emptyImageBox()),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 5, 5),
                                height: MediaQuery.of(context).size.width,
                                child: selectedPhoto.length > 4
                                    ? selectedBoxContainer(4)
                                    : emptyImageBox()),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                height: MediaQuery.of(context).size.width,
                                child: selectedPhoto.length > 5
                                    ? selectedBoxContainer(5)
                                    : emptyImageBox()),
                          ),
                        ],
                      ),
                    ),

                    //프로필 미리보기 영역 끝------
                    //앨범 드롭다운 리스트 시작-----
                    Container(
                      height: 35,
                      padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                      child: _albums.isNotEmpty
                          ? DropdownButton(
                              underline: SizedBox.shrink(),
                              value: _currentAlbum,
                              items: _albums
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          e.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) =>
                                  getPhotos(value!, albumChange: true),
                            )
                          : const SizedBox(),
                    ),
                    //앨범 드롭다운 리스트 끝-----
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scroll) {
                  final scrollPixels =
                      scroll.metrics.pixels / scroll.metrics.maxScrollExtent;
                  // print('scrollPixels = $scrollPixels');
                  if (scrollPixels > 0.7) getPhotos(_currentAlbum);

                  return false;
                },
                child: SafeArea(
                    child: _paths == null
                        ? const Center(child: CircularProgressIndicator())
                        : GridView.builder(
                            itemCount: _images.length,
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4),
                            itemBuilder: (BuildContext context, int index) {
                              print("index: " + index.toString());
                              _photo.add(Photo(
                                  images: _images[index],
                                  selected: false,
                                  count: index,
                                  selectedCount: 100));
                              return InkWell(
                                onTap: () {
                                  checkBoxCount(index, "bottomPhoto");
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        border: _photo[index].selected
                                            ? Border.all(
                                                width: 1, color: Colors.black)
                                            : Border.all(width: 0)),
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          child: AssetEntityImage(
                                            _images[index],
                                            isOriginal: false,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            // color: Colors.red,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: <Widget>[
                                                Container(
                                                    width: 25,
                                                    height: 25,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        selectedCountBoxContainer(
                                                            index),
                                                      ],
                                                    )),
                                              ],
                                            )),
                                      ],
                                    )),
                              );
                            })),
              ),
            ),
          ],
        ));
  }

  // Widget galleryPhotosContainer(){
  //
  // }

  Widget emptyImageBox() => Container(
        decoration: BoxDecoration(
            color: Color(0xffD0D0D0),
            image: DecorationImage(image: AssetImage('assets/emptyImage.png'))),
      );

  //선택 된 이미지 박스 번호
  Widget selectedCountBoxContainer(int index) {
    return Text(
        _photo[index].selected
            ? (_photo[index].selectedCount + 1).toString()
            : " ",
        style: TextStyle(
            fontSize: 15,
            color: Color(0xffFFFFFF),
            fontWeight: FontWeight.bold));
  }

  //프로필 미리보기 박스(선택 된 이미지 컨테이너)
  Widget selectedBoxContainer(int index) {
    print("selectedBoxContainer Index : " + index.toString());
    if (selectedPhoto.length != 0) {
      // if (selectedPhoto[index].selected) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: selectedPhoto[index].cropStatus == false
                    ? selectedPhoto[index].selected
                        ? AssetEntityImage(
                            selectedPhoto[index].images,
                            isOriginal: false,
                            fit: BoxFit.cover,
                          )
                        : SizedBox()
                    : kIsWeb
                        ? Image.network(
                            selectedPhoto[index].cropImagePath.toString())
                        : Image.file(
                            File(selectedPhoto[index].cropImagePath.toString()))
                // : Text("asd"),
                ),


            Positioned(
              bottom: 0,
              child: InkWell(
                onTap: () {
                  _cropImage(index);
                },
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.crop,
                    color: Color(0xffFFFFFF),
                    size: 15,
                  ),
                ),
              ),
            ),

            index == 0
                ? Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        // _cropImage(index);
                      },
                      child: Container(
                        height: 25,
                        padding: EdgeInsets.fromLTRB(5, 6, 5, 5),
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular((10))),
                        child: Text(
                          "대표사진",
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  )
                : index == 1
                    ? Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            // _cropImage(index);
                          },
                          child: Container(
                            height: 25,
                            padding: EdgeInsets.fromLTRB(5, 6, 5, 5),
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular((10))),
                            child: Text(
                              "커버사진",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    : SizedBox(),

            index == 0 && selectedPhoto[index].cropStatus == false
                ? InkWell(
                    onTap: () {
                      _cropImage(index);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.red.withOpacity(0.4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "노출되고 싶은 위치를\n지정해주세요.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ))
                : index == 1 && selectedPhoto[index].cropStatus == false
                    ? InkWell(
                        onTap: () {
                          _cropImage(index);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          color: Colors.red.withOpacity(0.4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "노출되고 싶은 위치를\n지정해주세요.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ))
                    : SizedBox(),
            //느낌표, X 표시
            Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // 느낌표
                    InkWell(
                      onTap: () {},
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.question_mark_sharp,
                          color: Color(0xffFFFFFF),
                          size: 15,
                        ),
                      ),
                    ),
                    // X 표시
                    InkWell(
                      onTap: () {
                        checkBoxCount(index, "topPhoto");
                      },
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Color(0xffFFFFFF)),
                      ),
                    ),
                  ],
                )),


          ],
        ),
      );
    } else {
      return Container(
        color: Colors.red,
      );
    }
  }

  //이미지 박스 선택 시
  void checkBoxCount(int index, String at) {
    if (at == "topPhoto") {
      //topPhoto에서 인덱스는 미리보기에 있는 인덱스
      print(selectedPhoto[index].imageIndex);
      //먼저 selectedPhoto에서 선택 된 이미지가 photo의 몇번 인덱스에 있는지 확인
      final index2 = _photo.indexWhere(
          (element) => element.count == selectedPhoto[index].imageIndex);

      //찾은 인덱스를 넣어서 체크 해제 처리하기
      setState(() {
        selectedPhoto.removeAt(index);
        _photo![index2].selected = false;
        selectedCount--;
      });

      //사진 리스트를 다시 그려주는 부분
      for (var i = 0; i < selectedPhoto.length; i++) {
        final index3 = _photo.indexWhere(
            (element) => element.selectedCount == selectedPhoto[i].count);
        setState(() {
          _photo[index3].selectedCount = i;
          selectedPhoto[i].count = i;
        });
      }
    } else {
      //bottomPhoto에서 인덱스는 앨범 리스트에 있는 사진 자리 인덱스
      print(at + " : " + index.toString());
      setState(() {
        listCount = 0;
      });
      if (selectedPhoto.length > 5) {
        print("selectedCount >= 5 여기로 들어왔어");
        if (_photo![index].selected) {
          setState(() {
            //체크 해제 처리
            _photo![index].selected = false;
            selectedPhoto.removeAt(_photo![index].selectedCount);

            //재배열
            for (var i = 0; i < selectedPhoto.length; i++) {
              final index2 = _photo.indexWhere(
                  (element) => element.selectedCount == selectedPhoto[i].count);
              setState(() {
                _photo[index2].selectedCount = i;
                selectedPhoto[i].count = i;
              });
            }
            selectedCount--;
          });
        } else {
          showToast("6장만 등록가능합니다.");
        }
      } else {
        //불협화음이 나오는곳
        print(" index: " + index.toString());
        print("_photo![index].selectedCount: " +
            _photo![index].selectedCount.toString());
        if (_photo![index].selected) {
          setState(() {
            //선택 된 박스 해제
            _photo![index].selected = false;
            //선택 된 사진 리스트에서 전체 사진 리스트에서 삭제
            selectedPhoto.removeAt(_photo![index].selectedCount);
            for (var i = 0; i < selectedPhoto.length; i++) {
              selectedCount=i;
              print("selectedCount: "+ selectedCount.toString());

              final index2 = _photo.indexWhere(
                  (element) => element.selectedCount == selectedPhoto[i].count);
              setState(() {
                _photo[index2].selectedCount = selectedCount;
                print("index2: "+ index2.toString());
                print("_photo[index2].selectedCount: "+ _photo[index2].selectedCount.toString());
                selectedPhoto[i].count = selectedCount;
              });
            }
            // selectedCount--;
          });
        } else {
          setState(() {
            selectedCount++;
            print("checkBoxCount._photo:  " + _photo.length.toString());
            print("checkBoxCount.i:  " + index.toString());

            for(var i =0;i<_photo.length;i++){
              print("checkBoxCount.i:  " + i.toString());
              print("checkBoxCount.photoCount:  " + _photo[i].count.toString());
            }
            _photo![index].selected = true;
            selectedPhoto.add(SelectedPhoto(
              images: _photo![index].images,
              selected: true,
              count: selectedCount,
              imageIndex: index,
              cropStatus: false,
            ));
            // selectedPhoto[selectedPhoto.length].count=selectedPhoto.length;
            _photo![index].selectedCount = selectedCount;
            // for (var i = 0; i < selectedPhoto.length; i++) {
            //   final index2 = _photo.indexWhere(
            //       (element) => element.selectedCount == selectedPhoto[i].count);
            //   setState(() {
            //     _photo[index2].selectedCount = i;
            //     selectedPhoto[i].count = i;
            //   });
            // }
          });
        }
      }
    }
  }

  void showToast(text) {
    Fluttertoast.showToast(msg: text.toString(), gravity: ToastGravity.BOTTOM);
  }
}
